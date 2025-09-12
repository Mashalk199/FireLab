//
//  FireResultView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI
import Foundation

/// This object stores the data that is to be either displayed in this screen or sent to the FireGraphsView page.
final class RetirementData: ObservableObject {
    @Published var brokerageGrowthData: [Double] = []
    @Published var retirementData: Result = Result(
        workingDays: 0,
        retirementDate: Date(),
        brokerProp: 0.5,
        monthlyBrokerContribution: 0,
        monthlySuperContribution: 0,
        brokerageBalanceAtRetirement: 0,
        superBalanceAtRetirement: 0,
    )

}
/// This struct stores only the data that is to be displayed in the current page to the user
struct Result {
        let workingDays: Int
        let retirementDate: Date
        let brokerProp: Double
        let monthlyBrokerContribution: Double
        let monthlySuperContribution: Double
        let brokerageBalanceAtRetirement: Double
        let superBalanceAtRetirement: Double
    }

/** This page displays the results of the retirement calculation performed by the app. It displays the date the user will retire, the value the superannuation and brokerage fund will be at retirement, as well as the monthly contribution that is necessary for both super and brokerage in order to achieve that goal. */
struct FireResultView: View {
    @EnvironmentObject var inputs: FireInputs
    @ObservedObject var retirementData: RetirementData
    
    
    
    @State private var isCalculating = true
    @State private var result: Result?

    var body: some View {
        VStack(spacing: 20) {
                    FireLogo().padding(.top, 8)

                    // Show a plain loading screen first
                    if isCalculating {
                        Spacer()
                        Text("Calculating…")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("This might take a minute")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Spacer()
                    } else if let r = result {
//                        retirementData.retirementData = r
                        
                        let years  = r.workingDays / 365
                        let months = (r.workingDays % 365) / 30

                        Text("\(years) years")
                            .font(.system(size: 44, weight: .bold))
                            .padding(.top, 10)

                        Text("\(months) Months\nuntil you reach financial independence")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)

                        Text("Retirement date: \(r.retirementDate.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundStyle(.secondary)

                        VStack(spacing: 6) {
                            Text("Brokerage at retirement: $\(String(format: "%.0f", r.brokerageBalanceAtRetirement))")
                                .accessibilityLabel("Brokerage at retirement \(r.brokerageBalanceAtRetirement, format: .currency(code: "AUD"))")

                            Text("Super at retirement: $\(String(format: "%.0f", r.superBalanceAtRetirement))")
                                .accessibilityLabel("Super at retirement \(r.superBalanceAtRetirement, format: .currency(code: "AUD"))")
                        }
                        .font(.headline)

                        VStack(spacing: 4) {
                            Text("Proportion to Brokerage: \(String(format: "%.2f%%", r.brokerProp * 100))")
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("Proportion allocated to Brokerage, \(r.brokerProp * 100, specifier: "%.1f") percent")
                            
                            Text("Recommended Monthly Contribution To Brokerage: $\(String(format: "%.0f", r.monthlyBrokerContribution))")
                                .accessibilityLabel("Recommended Monthly Contribution To Brokerage: $\(r.monthlyBrokerContribution, format: .currency(code: "AUD"))")
                            
                            Text("Recommended Monthly Contribution To Super: $\(String(format: "%.0f", r.monthlySuperContribution))")
                                .accessibilityLabel("Recommended Monthly Contribution To Super: $\(r.monthlySuperContribution, format: .currency(code: "AUD"))")
                        }

                        Spacer()

                        HStack(spacing: 14) {
                            SmallNavButton(text: "View Graphs", icon: "arrow.right.circle",
                                           width: 150, fgColor: .white, bgColor: .orange, border: .black.opacity(0.2), hint: "Opens graphs page") {
                                FireGraphsView(retirementData: retirementData)
                            }
                            SmallNavButton(text: "Home", icon: "arrow.clockwise.circle",
                                           width: 150, fgColor: .orange, bgColor: .white, border: .black, hint: "Returns to home page") {
                                ContentView()
                            }
                        }
                        .padding(.bottom, 12)
                    }
        
                }
        .onAppear {
            // Compute method off the main thread
            isCalculating = true
            DispatchQueue.global(qos: .userInitiated).async {
                let r = calculateRetirement()
                DispatchQueue.main.async {
                    self.result = r
                    self.isCalculating = false
                }
            }
        }
    }
    /** Converts annual return to the amount compounded daily.
     - Logic: Since compounding x times requires you to multiply by a return factor to the power of x, we can do the inverse to get the value compounding at a more regular interval.
     - Parameters:
            - percentage: The factor by which the investment amount will grow by when its growth is compounded, in this case every year, as a double value.
            - annual_inflation: The inflation factor for each year, as a double value.
     - Returns:
            - The factor by which the investment grows by on a daily basis, taking into account inflation.
     */
    func getDailyReturn(_ percentage: Double,_ annual_inflation: Double) -> Double {
        return pow(((1.0 + percentage) / (1.0 + annual_inflation)), (1.0/365.0))
    }
    /** Returns the proportions of the FI contribution to be allocated for brokerage and for super, based on the brokerage proportion provided. Given a specific brokerage proportion, the rest of the proportion will be allocated to super, by subtracting 1.
     - Parameters:
            - proportion: The brokerage proportion of the FI contribution
     - Returns:
            - A tuple where the first value is the proportion allocated for brokerage, and the super proportion as the second value.
     */
    func getProps(_ proportion: Double) -> (Double, Double) {
        return (proportion, 1.0 - proportion)
    }
    /**
     Returns the number of days in between 2 specific dates
     - Parameters:
            - startDate: A swift date object representing the first date in the interval you want to calculate the days between.
            - endDate: a swift date object representing the last date in the interval
     - Returns:
            - The number of days passing between the start and end dates provided.
     */
    func daysBetween(_ startDate: Date,_ endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    /**
     Converts and returns the numerical value inside the string variable storing the user's input, in a double format.
     - Parameters:
            - string: A string that likely is provided by the FireInputs environment object, containing the user's input for a particular piece of numerical data.
     - Returns:
            - The numerical value inside the string, after the string is trimmed from whitespace, as a double.
     */
    func getDouble(_ string: String) -> Double {
        return Double(string.trimmingCharacters(in: .whitespaces))
        ?? 2000 // Fallback value that causes extreme calculations, making debugging clearer
    }
    /**
     Uses all data gathered from user and calculates the proportion of the user's monthly FI contribution to allocate to brokerage funds, and the proportion to allocate to super funds, as well as the earliest possible time the user can retire by if they follow the plan.
     
     - Parameters:
            - FireInputs object with all fields filled by the user.
            - A RetirementData observable object that is accessible from the FireGraphsView screen. This object needs just a basic initialisation so that this method can fill in its details.
     - Returns:
            - A Result object that contains all data filled out by this function for it to be displayed in this FireResultView screen.
     */
    func calculateRetirement() -> Result {
        var daily_expenses: Double = getDouble(inputs.expensesText)
        daily_expenses /= 365
        var dailyFiCont: Double = getDouble(inputs.FIContributionText)
        dailyFiCont /= 365
//        var age_in_days: Int = daysBetween(inputs.dateOfBirth, Date())
        var portfolio: Double = 0
        var superGrowth: Double = 0
        
        var retiredBroker = false
        var retiredSuper = false
        var workingDays: Int = 0
        var totalRetiredDays: Int = 0
        var totalRetiredSuperDays: Int = 0
        let annual_inflation: Double = getDouble(inputs.inflationRateText) / 100.0
        let superAnnual     = getDouble(inputs.superGrowthRateText) / 100.0
        let superGrowthRate = getDailyReturn(superAnnual, annual_inflation)
        let ETFList = inputs.items
        
        let days_during_super = 7 * 365
        guard let d60 = Calendar.current.date(byAdding: .year, value: 60, to: inputs.dateOfBirth),
              let d67 = Calendar.current.date(byAdding: .year, value: 67, to: inputs.dateOfBirth) else {
            return Result(
                workingDays: 0,
                retirementDate: Date(),
                brokerProp: 0.5,
                monthlyBrokerContribution: 0,
                monthlySuperContribution: 0,
                brokerageBalanceAtRetirement: 0,
                superBalanceAtRetirement: 0,
            )
        }
        let days_to_60 = daysBetween(Date(), d60)
        let days_to_67 = daysBetween(Date(), d67)
        var remain_to_60 = 0
        var potential_pre60: Int = 0

        var (brokerProp, superProp): (Double, Double) = getProps(0.5)
        var (brokerCont, superCont): (Double, Double) = (0, 0)
        var (minProp, maxProp): (Double, Double) = (0, 1)

        var final_pre60_days: Int? = nil
        var final_post60_days: Int? = nil
        var brokerListGrowth: [Double] = []

        var allocation_tmp: Double = 0
        var return_tmp: Double = 0
        var retiredDays_tmp: Int = 0
        var retiredSuperDays_tmp: Int = 0
        var portfolioList: [Double] = []
        var pre60_growth_tmp: Double = 0
        var post60_growth_tmp: Double = 0
        
        var brokerageUsage: [Double] = []


        // 15 epochs is more than enough to perform an adequate binary search
        for _ in 1...15 {
            brokerListGrowth = Array(repeating: 0.0, count: ETFList.count)
            superGrowth = 0
            // Keeps track of how much the user is currently expected to work
            workingDays = 0
            // Flags keep track of whether user retired on brokerage and/or on super
            retiredBroker = false
            retiredSuper = false
            
            brokerageUsage = []
            
            /* Because either of the retired broker days or super days can get reset during
              the outer for loop, we use these outer variables to store the days of retirement */
            final_pre60_days = nil      // Capture once when brokerage becomes first feasible
            final_post60_days = nil     // Capture once when super becomes first feasible
            
            /* Runs while the number of day of work is less than the days it takes to reach 67
                as by then the user will retire, and while the user isn't retired. */
            while workingDays < days_to_67 && !(retiredBroker && retiredSuper) {
                /* Allocates portions of the Financial Independence contribution to super and brokerage
                 based on the current proportions of brokerage and super*/
                brokerCont = brokerProp * dailyFiCont
                superCont  = superProp  * dailyFiCont
                
                // Iterates through each investment item and grows them based on how much allocation they have
                for j in 0..<ETFList.count {
                    allocation_tmp = getDouble(ETFList[j].allocationPercent)
                    brokerListGrowth[j] += brokerCont * (allocation_tmp / 100.0)
                    brokerListGrowth[j] *= getDailyReturn(
                        getDouble(ETFList[j].expectedReturn) / 100.0,
                        annual_inflation)
                }
                // Store the growth of the brokerage investments for future graph plotting
                brokerageUsage.append(brokerListGrowth.reduce(0, +))

                // Grow super by 1 day of investments
                superGrowth += superCont
                superGrowth *= superGrowthRate
                
                workingDays += 1
                
                retiredDays_tmp = 0
                retiredSuperDays_tmp = 0
                
                portfolioList = brokerListGrowth
                /* Here we reduce the current value of the brokerage investment to basically zero, to
                 see whether the user can retire on it until the age of 60 or not. If the user reaches 60
                 without retiring, the retiredBroker flag remains false, and the brokerage investment
                 will continue to grow via more working days. */
                // .reduce(0, +) gets the total sum of the array
                while portfolioList.reduce(0, +) >= daily_expenses &&
                        !retiredBroker &&
                        (workingDays + retiredDays_tmp < days_to_60) {
                    for j in 0..<ETFList.count {
                        allocation_tmp = getDouble(ETFList[j].allocationPercent)
                        portfolioList[j] -= daily_expenses * (allocation_tmp / 100.0)
                        return_tmp = getDouble(ETFList[j].expectedReturn) / 100.0
                        portfolioList[j] *= getDailyReturn(return_tmp, annual_inflation)

                    }
                    retiredDays_tmp += 1
                    if workingDays + retiredDays_tmp >= days_to_60 {
                        retiredBroker = true
                        final_pre60_days = retiredDays_tmp
                    }
                }
                // how many days until 60 from "now"
                remain_to_60 = max(0, days_to_60 - workingDays)
                // balance AT 60 if user retires now
                portfolio = superGrowth * pow(superGrowthRate, Double(remain_to_60))
                // Super is also reduced to 0, to see whether retirement is possible
                while portfolio >= daily_expenses && !retiredSuper {
                    portfolio -= daily_expenses
                    portfolio *= superGrowthRate
                    retiredSuperDays_tmp += 1
                    if retiredSuperDays_tmp >= days_during_super {
                        retiredSuper = true
                        final_post60_days = retiredSuperDays_tmp
                    }
                }
                
                /* Ensures if the FI contribution is too low,
                    then by the time the user reaches 67 they will retire */
                if workingDays >= days_to_67 {
                    retiredBroker = true
                    retiredSuper  = true
                }
            }
            
            totalRetiredDays = 0
            portfolioList = brokerListGrowth
            /* Here we see the magnitude of how long the brokerage investment will last the user
             without stopping the reduction of the value of the brokerage when the user reaches the
             age of preservation. The value will keep decreasing until it is basically zero. This gives the
             actual value of how long the investment could fully last*/
            while portfolioList.reduce(0, +) >= daily_expenses {
                for j in 0..<ETFList.count {
                    allocation_tmp = getDouble(ETFList[j].allocationPercent)
                    portfolioList[j] -= daily_expenses * (allocation_tmp / 100.0)
                    return_tmp = getDouble(ETFList[j].expectedReturn)
                    portfolioList[j] *= getDailyReturn(return_tmp / 100.0, annual_inflation)
                }
                totalRetiredDays += 1
            }
            remain_to_60 = max(0, days_to_60 - workingDays)
            totalRetiredSuperDays = 0
            portfolio = superGrowth * pow(superGrowthRate, Double(remain_to_60))
            // This loop gives the true value of how long the super could fully last
            while portfolio >= daily_expenses {
                portfolio -= daily_expenses
                portfolio *= superGrowthRate
                totalRetiredSuperDays += 1
            }
            // Number of days user can retire early, before 60
            potential_pre60 = max(1, days_to_60 - workingDays) // avoid /0 when retiring at/after 60
            
            /* Here we calculate sort of like a "gradient" to see which range we should look to proportion
             the financial independence contribution towards brokerage funds or super funds to ensure earliest
             retirement.*/
             
             /* The magnitude of how much brokerage growth is achieved in this epoch (eg. totalRetiredDays) compared to the necessary
             minimum amount (eg. potential_pre60 */
            pre60_growth_tmp = Double(totalRetiredDays)/Double(potential_pre60)
            post60_growth_tmp = Double(totalRetiredSuperDays)/Double(days_during_super)
            /* If the ratio of actual retired days before 60 to potential retired days
            before 60 is less than the ratio of actual retired days before 67 to
            potential retired days after 60, increase the proportion of funds sent to brokerage */
            if pre60_growth_tmp < post60_growth_tmp {
                // Here we increase the minimum proportion of the brokerage funds in order to increase
                // the brokerage proportion, using min-max averaging
                minProp = brokerProp
            }
            else {
                maxProp = brokerProp
            }
            /* This min-max averaging approach allows us to perform a binary search to find the best
                Allocation of proportions to be sent to brokerage and super */
            (brokerProp, superProp) = getProps((minProp + maxProp) / 2)
            
            print("work=\(Double(workingDays)/365.0), " +
                  "retired=\(Double((final_pre60_days ?? 0) + (final_post60_days ?? 0))/365.0), ")
            print("brokerProp=\(brokerProp), brokerGrowth=\(brokerListGrowth.reduce(0, +)), superGrowth=\(superGrowth)")
        }


        
        // final summary values
        let retirementDate = Calendar.current.date(byAdding: .day, value: workingDays, to: Date()) ?? Date()
        let monthlyTotal   = getDouble(inputs.FIContributionText) / 12.0
        let monthlyBroker  = brokerProp * monthlyTotal
        let monthlySuper   = (1.0 - brokerProp) * monthlyTotal
        let brokerageAtRet = brokerListGrowth.reduce(0, +)

        // super balance at 60 if retiring now from last epoch state
        let remain_to_60_final = max(0, days_to_60 - workingDays)
        let superAt60 = superGrowth * pow(superGrowthRate, Double(remain_to_60_final))
        
        
        retiredDays_tmp = 0
        retiredSuperDays_tmp = 0
        retiredBroker = false
        retiredSuper = false
        
        portfolioList = brokerListGrowth
        // .reduce(0, +) gets the total sum of the array
        while portfolioList.reduce(0, +) >= daily_expenses &&
                !retiredBroker &&
                (workingDays + retiredDays_tmp < days_to_60) {
            for j in 0..<ETFList.count {
                allocation_tmp = getDouble(ETFList[j].allocationPercent)
                portfolioList[j] -= daily_expenses * (allocation_tmp / 100.0)
                return_tmp = getDouble(ETFList[j].expectedReturn) / 100.0
                portfolioList[j] *= getDailyReturn(return_tmp, annual_inflation)

            }
            brokerageUsage.append(portfolioList.reduce(0, +))
            retiredDays_tmp += 1
            if workingDays + retiredDays_tmp >= days_to_60 {
                retiredBroker = true
            }
        }
        retirementData.brokerageGrowthData = brokerageUsage

        return Result(
            workingDays: workingDays,
            retirementDate: retirementDate,
            brokerProp: brokerProp,
            monthlyBrokerContribution: monthlyBroker,
            monthlySuperContribution: monthlySuper,
            brokerageBalanceAtRetirement: brokerageAtRet,
            superBalanceAtRetirement: superAt60,
        )
    }

    
    
    
}



#Preview {
    NavigationStack {
        FireResultView(retirementData: RetirementData())
            .environmentObject(FireInputs())
    }
}

