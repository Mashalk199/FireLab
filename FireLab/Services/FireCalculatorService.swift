//
//  FireCalculator.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 5/10/2025.
//


//  FireCalculator.swift
//  FireLab

import Foundation
/**
 In this service class we perform the retirement simulation for the app user. We define some helper methods, and we
 use the FireInputs environment to gather all user input data, convert them into appropriate data structures and use them in
 mathematical calculations and machine learning.
 */
struct FireCalculatorService {
    private let dataService: FinancialDataFetching
    private let fullForecaster: Forecasting
    private let shortForecaster: Forecasting

    init(
        dataService: FinancialDataFetching = FinancialDataService(),
        fullForecaster: Forecasting = try! MLForecastService(modelType: .full),
        shortForecaster: Forecasting = try! MLForecastService(modelType: .short)
    ) {
        self.dataService = dataService
        self.fullForecaster = fullForecaster
        self.shortForecaster = shortForecaster
    }
    let DAYS_IN_YEAR: Double = 365.0
    // Add an approximate “days per month” step for monthly sampling
    private let DAYS_PER_MONTH: Int = 30

    // Nominal daily factor for DEBT interest compounding
    private func dailyDebtFactor(_ annualNominal: Double) -> Double {
        pow(1.0 + max(0.0, annualNominal), 1.0 / DAYS_IN_YEAR)
    }

    /**
     Converts annual return to the amount compounded daily.
     - Logic: Since compounding x times requires you to multiply by a return factor to the power of x, we can do the inverse to get the value compounding at a more regular interval.
     */
    private func getDailyReturn(_ percentage: Double,_ annual_inflation: Double) -> Double {
        pow(((1.0 + percentage) / (1.0 + annual_inflation)), (1.0/365.0))
    }
    
    // for test
    func _test_dailyReturn(annualReturn: Double, inflation: Double) -> Double {
        pow(((1.0 + annualReturn) / (1.0 + inflation)), (1.0/365.0))
    }

    /**
     Returns the proportions of the FI contribution to be allocated for brokerage and for super, based on the brokerage proportion provided.
     */
    private func getProps(_ proportion: Double) -> (Double, Double) {
        (proportion, 1.0 - proportion)
    }

    /**
     Converts and returns the numerical value inside the string variable storing the user's input, in a double format.
     */
    private func getDouble(_ string: String) -> Double {
        Double(string.trimmingCharacters(in: .whitespaces)) ?? 2000
    }

    /**
     Withdraw up to `amount` from `vec` in proportion to `weights` (or value-weighted if nil).
     - Returns leftover amount not covered (>= 0).
     */
    private func withdrawProRata(_ vec: inout [Double], weights: [Double]?, amount: Double) -> Double {
        guard !vec.isEmpty, amount > 0 else { return amount }
        // Number of assets
        let n = vec.count
        // Total value of all assets
        let total = vec.reduce(0,+)
        // The weights to be used later to reduce each of the assets by.
        let w: [Double]
        // If weights is provided and is above zero
        if let weights, weights.reduce(0,+) > 0 {
            w = weights
        } else {
            // If the vector sum is above 0, weight them by values. Otherwise provide a default even weight array.
            w = total > 0 ? vec.map { $0 / total } : Array(repeating: 1.0 / Double(n), count: n)
        }
        let avail = vec.reduce(0,+)
        // Use the available funds as the total, if smaller than amount
        let take = min(amount, avail)
        if take > 0 {
            // For each asset, reduce their value by their weight multiplied by the take.
            for i in vec.indices {
                vec[i] = max(0.0, vec[i] - take * w[i])
            }
        }
        return amount - take
    }
    
    // for test
    func _test_withdraw(_ vec: inout [Double], weights: [Double]?, amount: Double) -> Double {
        withdrawProRata(&vec, weights: weights, amount: amount)
    }

    /**
     Returns the number of days in between 2 specific dates
     */
    private func daysBetween(_ startDate: Date, _ endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }

    // MARK: - Public entry point used by the ViewModel

    /** Uses all data gathered from user and calculates the retirement result. */
    func calculateRetirement(inputs: FireInputs) async throws -> Result {
        
        var daily_expenses: Double = getDouble(inputs.expensesText) / DAYS_IN_YEAR
        let yearlyTotalFI = max(0.0, getDouble(inputs.FIContributionText))   // yearly total
        let monthlyTotal  = yearlyTotalFI / 12.0                              // derive monthly
        let dailyFI       = yearlyTotalFI / DAYS_IN_YEAR                      // derive daily
        
        let annual_inflation: Double = getDouble(inputs.inflationRateText) / 100.0
        let superAnnual: Double      = getDouble(inputs.superGrowthRateText) / 100.0
        let superGrowthRate          = getDailyReturn(superAnnual, annual_inflation)
        
        // explicit branch by user choice
        switch inputs.housingType {
        case .mortgage:
            break
        case .rent:
            let weeklyRent = max(0.0, getDouble(inputs.weeklyRentText))
            if weeklyRent > 0 {
                let annualRent = weeklyRent * 52.0
                daily_expenses += annualRent / DAYS_IN_YEAR
            }
        }
        
        // Future brokerage bucket = ETFs + Bonds
        let futureBrokerage = inputs.investmentItems.filter { $0.type == .etf || $0.type == .bond }
        
        // Weighted nominal hurdle from all future brokerage (for debt avalanche after mins)
        let investHurdleAnnual: Double = {
            guard !futureBrokerage.isEmpty else { return 0.0 }
            let weighted = futureBrokerage.map {
                (max(0.0, getDouble($0.allocationPercent)) / 100.0) *
                (max(0.0, getDouble($0.expectedReturn) / 100.0))
            }.reduce(0, +)
            return weighted
        }()
        
        // -----------------
        // Phase A: debts
        // -----------------
        
        /*
         In this phase, we attempt to get rid of debts that have a higher growth rate than the "InvestHurdleAnnual" or the invest hurdle.
         InvestHurdleAnnual gets the total expected return that the user is expecting on their future portfolio. If the debt growth
         is higher than that, then it needs to be paid off as soon as possible to minimise loss and achieve retirement faster.
         */
        
        // Create a debts tuple to avoid using loanItems observableObject inefficiencies
        var debts: [(name: String, balance: Double, annualRate: Double, minDaily: Double, dailyFactor: Double)] =
        inputs.loanItems.map { li in
            let bal  = max(0.0, getDouble(li.outstandingBalance))
            let apr  = max(0.0, getDouble(li.interestRate) / 100.0)
            let minM = max(0.0, getDouble(li.minimumPayment))
            return (li.name, bal, apr, (minM * 12.0) / DAYS_IN_YEAR, dailyDebtFactor(apr))
        }
        
        // We add a mortgage to the list of debts if the user has selected mortgage as their housing type
        if inputs.housingType == .mortgage {
            let mBal  = max(0.0, getDouble(inputs.outstandingMortgageText))
            let mAPR  = max(0.0, getDouble(inputs.mortgageYearlyInterestText) / 100.0)
            let mMinM = max(0.0, getDouble(inputs.mortgageMinimumPaymentText))
            if mBal > 0 || mAPR > 0 || mMinM > 0 {
                debts.append((
                    name: "Mortgage",
                    balance: mBal,
                    annualRate: mAPR,
                    minDaily: (mMinM * 12.0) / DAYS_IN_YEAR,
                    dailyFactor: dailyDebtFactor(mAPR)
                ))
            }
        }
        
        print("--- Phase A start ---")
        let startDebtsStr = debts.map { "\($0.name)=\(String(format: "%.2f", $0.balance))" }.joined(separator: ", ")
        print("Initial debts: [\(startDebtsStr)]")
        
        // Tiny epsilon value
        let eps = 0.005
        let today = Date()
        let ageYearsNow = max(0.0, Double(daysBetween(inputs.dateOfBirth, today)) / DAYS_IN_YEAR)
        let maxDebtDays = Int(max(0.0, (67.0 - ageYearsNow)) * DAYS_IN_YEAR)
        
        var debtDays = 0
        
        /* Attempts to eliminate all debts that grow faster than the investHurdle.
         Once they are eliminated, the user can start investing in assets. */
        if !debts.isEmpty {
            func allCleared() -> Bool { debts.allSatisfy { $0.balance <= eps } }
            while debtDays < maxDebtDays && !allCleared() {
                // interest accrues
                for i in debts.indices where debts[i].balance > eps {
                    debts[i].balance *= debts[i].dailyFactor
                }
                // pay minimums (highest APR first)
                var fi_left = dailyFI
                debts.sort { $0.annualRate > $1.annualRate }
                for i in debts.indices {
                    guard fi_left > 0, debts[i].balance > eps else { continue }
                    let dueMin = min(debts[i].minDaily, debts[i].balance)
                    let pay = min(fi_left, dueMin)
                    debts[i].balance -= pay
                    fi_left -= pay
                }
                // avalanche toward debts whose APR >= hurdle
                if fi_left > 0 {
                    for i in debts.indices where debts[i].balance > eps && debts[i].annualRate >= investHurdleAnnual {
                        let pay = min(fi_left, debts[i].balance)
                        debts[i].balance -= pay
                        fi_left -= pay
                        if fi_left <= 0 { break }
                    }
                }
                debtDays += 1
                if debtDays % 365 == 0 {
                    let hb = debts.map { String(format: "%.2f", $0.balance) }.joined(separator: ", ")
                    print("Day \(debtDays): debts=[\(hb)]")
                }
            }
        }
        
        // If we hit 67 (or otherwise didn’t clear all debts), stop here.
        //let remainingAfterPhaseA = debts.filter { $0.balance > eps }.map { ($0.name, $0.balance) }
        
        let remainingAfterPhaseA: [DebtRemnant] =
        debts.filter { $0.balance > eps }.map { DebtRemnant(name: $0.name, balance: $0.balance) }
        
        let endDebtsStr = debts.map { "\($0.name)=\(String(format: "%.2f", $0.balance))" }.joined(separator: ", ")
        print("Phase A finished after \(debtDays) days. Debts now: [\(endDebtsStr)]")
        if !remainingAfterPhaseA.isEmpty {
            let retirementDate = Calendar.current.date(byAdding: .day, value: debtDays, to: today) ?? today
            return Result(
                workingDays: debtDays,
                retirementDate: retirementDate,
                brokerProp: 0.0,
                monthlyBrokerContribution: 0.0,
                monthlySuperContribution: 0.0,
                brokerageBalanceAtRetirement: 0.0,
                superBalanceAtRetirement: 0.0,
                debtClearDays: debtDays,
                remainingDebts: remainingAfterPhaseA,
                brokerageSeries: []
            )
        }
        
        // -----------------
        // Phase B: Retrieve financial data and perform machine learning
        // -----------------
        
        /*
         In Phase B we will fetch financial data from the api using our FinancialDataService and perform
         machine learning with the MLForecaseService
         */
        
        // Stores indices of all investments that are ETFs and have machine learning calculation enabled
        var etfIndices: [Int] = inputs.investmentItems.indices.filter { inputs.investmentItems[$0].type == .etf &&
                                                                        inputs.investmentItems[$0].autoCalc }
        
        var etfData: [Int: [Double]] = [:]

        for i in etfIndices {
            guard let snapshot = inputs.investmentItems[i].etfSnapshot else {
                throw FireCalcError.missingSnapshot(name: inputs.investmentItems[i].name)
            }
            let symbol = snapshot.symbol
            etfData[i] = try await dataService.fetchTimeSeries(symbol: symbol, endDate: Date())
            
            // Sleep for 8.5 seconds to respect our API rate limits
            try await Task.sleep(for: .seconds(8.5))
        }
        var predReturns: [Int: [Double]] = [:]
        // Filter out ETFs with fewer than 60 data points before applying machine learning
        etfIndices = etfIndices.filter { i in
            if let data = etfData[i] {
                return data.count >= 60
            } else {
//                print("No data for \(inputs.investmentItems[i].name)")
                return false
            }
        }
        // Here we apply machine learning and store the data into our predReturns dictionary
        for i in etfIndices {
            if let prices = etfData[i], prices.count >= 250 {
                predReturns[i] = try fullForecaster.predictReturns(closes: prices, steps: Int(DAYS_IN_YEAR) * 2)
            } else if let prices = etfData[i], prices.count >= 60 {
                predReturns[i] = try shortForecaster.predictReturns(closes: prices, steps: Int(DAYS_IN_YEAR) * 2)
            }
        }
        
        
        // -----------------
        // Phase C: invest and find retirement (bisection approach)
        // -----------------
        
        /*
         In Phase C we go through the users financial life from now until they retire, and calculate whether retirement is possible for every day.
         If not, the user works an additional day, otherwise they stop working. Funds are split between brokerage and super investments, so a binary-search bisection
         is performed to find the most optimal proportions to allocate to brokerage and to superannuation over 10 loops.
         
         Since we don't have to worry about the invest hurdle anymore, we can just focus on paying the debt minimums.
         */
        let workingDaysOffset   = debtDays
        let days_to_60          = max(0, Int((60.0 - ageYearsNow) * DAYS_IN_YEAR) - workingDaysOffset)
        let days_to_67          = max(0, Int((67.0 - ageYearsNow) * DAYS_IN_YEAR) - workingDaysOffset)
        let days_during_super   = Int(7.0 * DAYS_IN_YEAR)

        // “future” brokerage bucket (from futureBrokerage)
        let brkWeights = futureBrokerage.map { max(0.0, getDouble($0.allocationPercent) / 100.0) }
        let brkFactors = futureBrokerage.map {
            getDailyReturn(max(0.0, getDouble($0.expectedReturn) / 100.0), annual_inflation)
        }

        // current holdings bucket (PortfolioItem): grow only, withdraw value-weighted (EXCLUDE super)
        let nonSuperPortfolio = inputs.portfolioItems.filter { $0.type != .superannuation }
        let currFactors = nonSuperPortfolio.map {
            getDailyReturn(max(0.0, getDouble($0.expectedReturn) / 100.0), annual_inflation)
        }
        let startCurr   = nonSuperPortfolio.map { max(0.0, getDouble($0.value)) }

        // super
        let superFactor = superGrowthRate

        // Bisection state
        var (brokerProp, _) = getProps(0.5)
        var minProp = 0.0, maxProp = 1.0

        // Epoch seeds
        var brokerListGrowth = Array(repeating: 0.0, count: futureBrokerage.count)
        let currentSuperStart = inputs.portfolioItems
            .filter { $0.type == .superannuation }
            .map { max(0.0, getDouble($0.value)) }
            .reduce(0, +)

        var superGrowth = currentSuperStart
        // Keeps track of how much the user is currently expected to work
        var workingDays = 0

        print("futureBrokerage.count =", futureBrokerage.count)
        print("startCurr (existing brokerage) =", startCurr.reduce(0,+))

        var epochIndex = 0
        var series: [Double] = []
        for _ in 1...8 {
            epochIndex += 1
            series.removeAll()
            // epoch start prints
            let initDebts = debts.map { String(format: "%.2f", $0.balance) }.joined(separator: ", ")
            print("\n--- Epoch \(epochIndex) start ---")

            print("Initial template debts: [\(initDebts)]")
            brokerListGrowth = Array(repeating: 0.0, count: futureBrokerage.count)
            superGrowth = currentSuperStart
            workingDays = 0
            // Flags keep track of whether user retired on brokerage and/or on super
            var retiredBroker = false
            var retiredSuper  = false

            var currB = startCurr
            var debtsTemplate = debts // continue accruing mins/interest in Phase C

            /* Runs while the number of days of work (workingDays) is less than the days it takes to reach 67
                as by then the user will retire, and while the user isn't retired. */
            while (workingDays < days_to_67) && !(retiredBroker && retiredSuper) {
                // Accrue interest on debts for this day (Phase C accrual)
                for i in debtsTemplate.indices where debtsTemplate[i].balance > eps {
                    debtsTemplate[i].balance *= debtsTemplate[i].dailyFactor
                }

                // Tracks the current amount of the daily FI contribution "currently" left to put towards loans and investments.
                var fi_left = dailyFI
                // First we will fulfil loan obligations by paying minimums
                debtsTemplate.sort { $0.annualRate > $1.annualRate }
                for i in debtsTemplate.indices {
                    if fi_left <= 0 { break }
                    if debtsTemplate[i].balance <= eps { continue }
                    let dueMin = min(debtsTemplate[i].minDaily, debtsTemplate[i].balance)
                    let pay    = min(fi_left, dueMin)
                    debtsTemplate[i].balance -= pay
                    fi_left -= pay
                }

                // broker_cont stores the proportion of money of the remainder of the FI contribution to be put towards all brokerage investments. Same with super_cont for superannuation
                let brokerCont = brokerProp * fi_left
                let superCont  = (1.0 - brokerProp) * fi_left

                // Grow investments: Iterates through each investment item and grows them based on how much allocation they have
                for j in brokerListGrowth.indices {
                    brokerListGrowth[j] += brokerCont * brkWeights[j]
                    // We only use machine learning predictions for the first 2 years, after that we rely on the user's provided return
                    if workingDays <= Int(DAYS_IN_YEAR) * 2 && etfIndices.contains(j) {
                        if let returns = predReturns[j], workingDays < returns.count {
                            brokerListGrowth[j] *= (1 + returns[workingDays] / 100.0)
                        }
                    }
                    else {
                        brokerListGrowth[j] *= brkFactors[j]
                    }
                }

                // Grow super by 1 day of investments
                superGrowth += superCont
                superGrowth *= superFactor

                // grow current holdings (no contributions)
                for i in currB.indices { currB[i] *= currFactors[i] }

                workingDays += 1
                
                // Append to series monthly during the working stage
                if workingDays % DAYS_PER_MONTH == 0 {
                    series.append( brokerListGrowth.reduce(0,+) + currB.reduce(0,+) )
                }

                if workingDays % 365 == 0 {
                    let hb = debtsTemplate.map { String(format: "%.2f", $0.balance) }.joined(separator: ", ")
                    print("Epoch \(epochIndex) – day \(workingDays): debts=[\(hb)]")
                }
                // brokerage pre-60 feasibility
                var retiredDays_tmp = 0
                var portfolioList   = brokerListGrowth
                var tempCurr        = currB
                var tempDebts       = debtsTemplate

                func sumAll() -> Double { portfolioList.reduce(0,+) + tempCurr.reduce(0,+) }
                

                /* Here, at the current workingDays, we reduce the current value of the brokerage investment to basically
                 zero over a period of time, to see whether the user can retire on it until the age of 60 or not.
                 If the user reaches 60 without retiring, the retiredBroker flag remains false, and the brokerage investment
                 will continue to grow via more working days. */
                // .reduce(0, +) gets the total sum of the array
                while sumAll() >= daily_expenses &&
                      !retiredBroker &&
                      (workingDays + retiredDays_tmp < days_to_60) {

                    // Grow past portfolio and future brokerage
                    for i in tempCurr.indices { tempCurr[i] *= currFactors[i] }
                    for j in portfolioList.indices {
                        /* The time since the simulation beginning is given by workingDays +
                        retiredDays_tmp, the amount of days we've currently attempted retiring on. */
                        if workingDays + retiredDays_tmp <= Int(DAYS_IN_YEAR) * 2 && etfIndices.contains(j) {
                            if let returns = predReturns[j], workingDays + retiredDays_tmp < returns.count {
                                portfolioList[j] *= (1 + returns[workingDays + retiredDays_tmp] / 100.0)
                            }
                        }
                        else {
                            portfolioList[j] *= brkFactors[j]
                        }
                    }
                    
                    // Calculate the total debt minimums due today
                    var dailyDebtDue = 0.0
                    for i in tempDebts.indices where tempDebts[i].balance > eps {
                        tempDebts[i].balance *= tempDebts[i].dailyFactor // optional inner-day accrual
                        dailyDebtDue += min(tempDebts[i].minDaily, tempDebts[i].balance)
                    }
                    
                    if dailyDebtDue > 0 {
                        // First pay off debt minimums with past portfolio
                        var leftover = withdrawProRata(&tempCurr, weights: nil, amount: dailyDebtDue)
                        // Pay remaining with current brokerage investments
                        if leftover > 0 { leftover = withdrawProRata(&portfolioList, weights: brkWeights, amount: leftover) }
                        // reflect paid mins
                        var toReduce = dailyDebtDue - max(0.0, leftover)
                        // Reduce debt value by how much was paid
                        for i in tempDebts.indices where toReduce > 0 && tempDebts[i].balance > eps {
                            // If remaining balance is lower than the minimum required payment, only pay outstanding
                            let due = min(tempDebts[i].minDaily, tempDebts[i].balance)
                            // If the amount left to pay off the debt is lower, subtract only that from the debt
                            let take = min(toReduce, due)
                            tempDebts[i].balance -= take
                            toReduce -= take
                        }
                    }

                    // Pay living expenses via withdrawal from current brokerage, then from the past portfolio
                    var rem = daily_expenses
                    rem = withdrawProRata(&tempCurr, weights: nil, amount: rem)
                    if rem > 0 { rem = withdrawProRata(&portfolioList, weights: brkWeights, amount: rem) }
                    if rem > 1e-9 { break } // couldn’t cover today. break feasibility for brokerage

                    retiredDays_tmp += 1
                    if workingDays + retiredDays_tmp >= days_to_60 {
                        retiredBroker = true
                    }
                }

                // super post-60 feasibility (compounds to 60 then simulate future days)
                
                // how many days until 60 from "now"
                let remain_to_60 = max(0, days_to_60 - workingDays)
                // balance AT 60 if user retires now
                var temp_super   = superGrowth * pow(superFactor, Double(remain_to_60))
                var retiredSuperDays_tmp = 0
                var tempDebtsSuper = debtsTemplate

                // Super is also reduced to 0, to see whether retirement is possible
                while temp_super >= daily_expenses && !retiredSuper {
                    for i in tempDebtsSuper.indices where tempDebtsSuper[i].balance > eps {
                        tempDebtsSuper[i].balance *= tempDebtsSuper[i].dailyFactor
                    }
                    
                    // Grow super
                    temp_super *= superFactor

                    // Pay debt minimums from super
                    var dailyDebtDue = 0.0
                    for d in tempDebtsSuper where d.balance > eps { dailyDebtDue += min(d.minDaily, d.balance) }
                    let pay = min(dailyDebtDue, temp_super)
                    temp_super -= pay
                    var toReduce = pay
                    for i in tempDebtsSuper.indices where toReduce > 0 && tempDebtsSuper[i].balance > eps {
                        let due = min(tempDebtsSuper[i].minDaily, tempDebtsSuper[i].balance)
                        let take = min(toReduce, due)
                        tempDebtsSuper[i].balance -= take
                        toReduce -= take
                    }

                    // Pay living expenses from super
                    if temp_super < daily_expenses { break }
                    temp_super -= daily_expenses

                    retiredSuperDays_tmp += 1
                    if retiredSuperDays_tmp >= days_during_super {
                        retiredSuper = true
                    }
                }
                /* Ensures if the FI contribution is too low,
                    then by the time the user reaches 67 they will retire */
                if workingDays >= days_to_67 {
                    retiredBroker = true
                    retiredSuper  = true
                    break
                }
            }

            // recompute full depletion lengths for “gradient”
            var totalRetiredDays = 0
            var portfolioList = brokerListGrowth
            var tempCurr = currB
            var tempDebtsGrad = debtsTemplate

            /* Here we see the magnitude of how long the brokerage investment will last the user
             without stopping the reduction of the value of the brokerage when the user reaches the
             age of preservation. The value will keep decreasing until it is basically zero. This gives the
             actual value of how long the investment could fully last*/
            while (portfolioList.reduce(0,+) + tempCurr.reduce(0,+)) >= daily_expenses {
                for i in tempDebtsGrad.indices where tempDebtsGrad[i].balance > eps {
                    tempDebtsGrad[i].balance *= tempDebtsGrad[i].dailyFactor
                }
                // Grow
                for i in tempCurr.indices { tempCurr[i] *= currFactors[i] }
                for j in portfolioList.indices {
                    /* The time since the simulation beginning is given by workingDays +
                    retiredDays_tmp, the amount of days we've currently attempted retiring on. */
                    if workingDays + totalRetiredDays <= Int(DAYS_IN_YEAR) * 2 && etfIndices.contains(j) {
                        if let returns = predReturns[j], workingDays + totalRetiredDays < returns.count {
                            portfolioList[j] *= (1 + returns[workingDays + totalRetiredDays] / 100.0)
                        }
                    }
                    else {
                        portfolioList[j] *= brkFactors[j]
                    }
                }
                // Pay debt minimums
                var dailyDebtDue = 0.0
                for d in tempDebtsGrad where d.balance > eps { dailyDebtDue += min(d.minDaily, d.balance) }
                if dailyDebtDue > 0 {
                    var left = withdrawProRata(&tempCurr, weights: nil, amount: dailyDebtDue)
                    if left > 0 { left = withdrawProRata(&portfolioList, weights: brkWeights, amount: left) }
                    var toReduce = dailyDebtDue - max(0.0, left)
                    for i in tempDebtsGrad.indices where toReduce > 0 && tempDebtsGrad[i].balance > eps {
                        let due = min(tempDebtsGrad[i].minDaily, tempDebtsGrad[i].balance)
                        let take = min(toReduce, due)
                        tempDebtsGrad[i].balance -= take
                        toReduce -= take
                    }
                }

                // Pay living expenses
                var rem = withdrawProRata(&tempCurr, weights: nil, amount: daily_expenses)
                if rem > 0 { rem = withdrawProRata(&portfolioList, weights: brkWeights, amount: rem) }
                if rem > 1e-9 { break }

                // Record monthly progress during depletion (to age 60) using the live depletion state
                let currentDay = workingDays + totalRetiredDays
                if currentDay % DAYS_PER_MONTH == 0 && currentDay <= days_to_60 {
                    series.append( portfolioList.reduce(0,+) + tempCurr.reduce(0,+) )
                }
                // Stop collecting beyond age 60 for the “retired stage” series
                if currentDay >= days_to_60 { break }

                totalRetiredDays += 1
            }

            let remain_to_60 = max(0, days_to_60 - workingDays)
            var totalRetiredSuperDays = 0
            var temp_super = superGrowth * pow(superFactor, Double(remain_to_60))
            var tempDebtsSuper2 = debtsTemplate

            // This loop gives the true value of how long the super could fully last
            while temp_super >= daily_expenses {
                for i in tempDebtsSuper2.indices where tempDebtsSuper2[i].balance > eps {
                    tempDebtsSuper2[i].balance *= tempDebtsSuper2[i].dailyFactor
                }
                // Grow super
                temp_super *= superFactor
                // Pay debt minimums
                var dailyDebtDue = 0.0
                for d in tempDebtsSuper2 where d.balance > eps { dailyDebtDue += min(d.minDaily, d.balance) }
                let pay = min(dailyDebtDue, temp_super)
                temp_super -= pay
                var toReduce = pay
                for i in tempDebtsSuper2.indices where toReduce > 0 && tempDebtsSuper2[i].balance > eps {
                    let due = min(tempDebtsSuper2[i].minDaily, tempDebtsSuper2[i].balance)
                    let take = min(toReduce, due)
                    tempDebtsSuper2[i].balance -= take
                    toReduce -= take
                }
                // Pay living expenses
                if temp_super < daily_expenses { break }
                temp_super -= daily_expenses

                totalRetiredSuperDays += 1
            }

            let potential_pre60 = max(1, days_to_60 - workingDays) // avoid /0 when retiring at/after 60
    
            /* Here we calculate something like a "gradient" to see which range we should look to proportion
             the financial independence contribution towards brokerage funds or super funds to ensure earliest
             retirement.*/
             
             /* This variable is the magnitude of how much brokerage growth is achieved in this epoch (eg. totalRetiredDays) compared to the necessary
             minimum amount (eg. potential_pre60) */
            let pre60_growth_tmp  = Double(totalRetiredDays) / Double(potential_pre60)
            let post60_growth_tmp = Double(totalRetiredSuperDays) / Double(days_during_super)

            // Debugging
            let finalDebts = debtsTemplate.map { String(format: "%.2f", $0.balance) }.joined(separator: ", ")
            let brokerTotal = String(format: "%.2f", brokerListGrowth.reduce(0,+))
            let superNow    = String(format: "%.2f", superGrowth)
            print("Epoch \(epochIndex) finished after \(workingDays) days")
            print("  Final debt balances: [\(finalDebts)]")
            print("  Broker prop = \(String(format: "%.3f", brokerProp)), Brokerage total = \(brokerTotal), Super = \(superNow)")
            
            /* If the ratio of "total potential" retired days before 60 compared to the minimum required retired days
            before 60 is less than the ratio of "total potential" retired days before 67 to
            minimum required retired days AFTER 60, then increase the proportion of funds sent to brokerage */
            if pre60_growth_tmp < post60_growth_tmp {
                // Here we increase the minimum proportion of the brokerage funds in order to increase
                // the brokerage proportion, using min-max averaging
                minProp = brokerProp
            } else {
                maxProp = brokerProp
            }
            let mid = (minProp + maxProp) / 2.0
            
            /* This min-max averaging approach allows us to perform a binary search to find the best
                Allocation of proportions to be sent to brokerage and super */
            (brokerProp, _) = getProps(mid)
        }

        // final summary values
        let retirementDate = Calendar.current.date(byAdding: .day, value: workingDays + workingDaysOffset, to: today) ?? today
        let monthlyBroker  = brokerProp * monthlyTotal
        let monthlySuper   = (1.0 - brokerProp) * monthlyTotal
        let brokerageAtRet = brokerListGrowth.reduce(0, +)

        let remain_to_60_final = max(0, days_to_60 - workingDays)
        let superAt60 = superGrowth * pow(superFactor, Double(remain_to_60_final))

        print("\n=== Final Summary ===")
        print("Working days: \(workingDays)")
        print("Retirement date: \(retirementDate)")
        print("Broker prop: \(String(format: "%.3f", brokerProp))")
        print("Monthly -> Broker: \(String(format: "%.0f", monthlyBroker)), Super: \(String(format: "%.0f", monthlySuper))")
        print("Brokerage @ retire: \(String(format: "%.0f", brokerageAtRet))")
        print("Super (at 60):      \(String(format: "%.0f", superAt60))")

        return Result(
            workingDays: workingDays,
            retirementDate: retirementDate,
            brokerProp: brokerProp,
            monthlyBrokerContribution: monthlyBroker,
            monthlySuperContribution: monthlySuper,
            brokerageBalanceAtRetirement: brokerageAtRet,
            superBalanceAtRetirement: superAt60,
            debtClearDays: debtDays,
            remainingDebts: [], // empty => Phase C completed
            brokerageSeries: series
        )
    }
}
/// Custom exception for when an ETFDoc is missing from the FireInputs object
enum FireCalcError: LocalizedError {
    case missingSnapshot(name: String)

    var errorDescription: String? {
        switch self {
        case .missingSnapshot(let name):
            return "Missing ETF snapshot for investment: \(name)"
        }
    }
}
