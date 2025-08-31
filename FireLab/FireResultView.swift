//
//  FireResultView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI
import Foundation

struct FireResultView: View {
    @EnvironmentObject var inputs: FireInputs

    struct Result {
            let workingDays: Int
            let retirementDate: Date
            let brokerProp: Double
            let monthlyBrokerContribution: Double
            let monthlySuperContribution: Double
            let brokerageBalanceAtRetirement: Double
            let superBalanceAtRetirement: Double
        }
    
    @State private var isCalculating = true
    @State private var result: Result?

    var body: some View {
        VStack(spacing: 20) {
                    Logo().padding(.top, 8)

                    // Show a plain loading screen first
                    if isCalculating {
                        Spacer()
                        Text("Calculating…")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("This might take a minute")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Spacer()
                    } else if let r = result {
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
                            Text("Super at retirement: $\(String(format: "%.0f", r.superBalanceAtRetirement))")
                        }
                        .font(.headline)

                        VStack(spacing: 4) {
                            Text("Proportion to Brokerage: \(String(format: "%.2f%%", r.brokerProp * 100))")
                                .foregroundStyle(.secondary)
                            Text("Recommended Monthly Contribution To Brokerage: $\(String(format: "%.0f", r.monthlyBrokerContribution))")
                            Text("Recommended Monthly Contribution To Super: $\(String(format: "%.0f", r.monthlySuperContribution))")
                        }

                        Spacer()

                        HStack(spacing: 14) {
                            SmallButton(text: "View Graphs", icon: "arrow.right.circle",
                                        width: 133, fgColor: .white, bgColor: .orange, border: .black.opacity(0.2)) {
                                //FireGraphsView()
                            }
                            SmallButton(text: "Home", icon: "arrow.clockwise.circle",
                                        width: 133, fgColor: .orange, bgColor: .white, border: .black) {
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
    
    func getAnnualReturn(_ percentage: Double,_ annual_inflation: Double) -> Double {
        return pow(((1.0 + percentage) / (1.0 + annual_inflation)), (1.0/365.0))
    }
    func getProps(_ proportion: Double) -> (Double, Double) {
        return (proportion, 1.0 - proportion)
    }
    func daysBetween(_ startDate: Date,_ endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    func getDouble(_ string: String) -> Double {
        return Double(string.trimmingCharacters(in: .whitespaces))
        ?? 2000 // Fallback value
    }
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
        let superGrowthRate = getAnnualReturn(superAnnual, annual_inflation)
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
                superBalanceAtRetirement: 0
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


        // 12 epochs is more than enough to perform an adequate binary search
        for _ in 1...12 {
            brokerListGrowth = Array(repeating: 0.0, count: ETFList.count)
            superGrowth = 0
            workingDays = 0
            retiredBroker = false
            retiredSuper = false
            
            /* Because either of the retired broker days or super days can get reset during
              the outer for loop, we use these outer variables to store the days of retirement */
            final_pre60_days = nil      // Capture once when brokerage becomes first feasible
            final_post60_days = nil     // Capture once when super becomes first feasible
            
            while workingDays < days_to_67 && !(retiredBroker && retiredSuper) {
                brokerCont = brokerProp * dailyFiCont
                superCont  = superProp  * dailyFiCont
                
                for j in 0..<ETFList.count {
                    allocation_tmp = getDouble(ETFList[j].allocationPercent)
                    brokerListGrowth[j] += brokerCont * (allocation_tmp / 100.0)
                    brokerListGrowth[j] *= getAnnualReturn(
                        getDouble(ETFList[j].expectedReturn) / 100.0,
                        annual_inflation)
                }
                // Grow super by 1 day of investments
                superGrowth += superCont
                superGrowth *= superGrowthRate
                
                workingDays += 1
                
                retiredDays_tmp = 0
                retiredSuperDays_tmp = 0
                
                portfolioList = brokerListGrowth
                // .reduce(0, +) gets the total sum of the array
                while portfolioList.reduce(0, +) >= daily_expenses &&
                        !retiredBroker &&
                        (workingDays + retiredDays_tmp < days_to_60) {
                    for j in 0..<ETFList.count {
                        allocation_tmp = getDouble(ETFList[j].allocationPercent)
                        portfolioList[j] -= daily_expenses * (allocation_tmp / 100.0)
                        return_tmp = getDouble(ETFList[j].expectedReturn) / 100.0
                        portfolioList[j] *= getAnnualReturn(return_tmp, annual_inflation)

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
            while portfolioList.reduce(0, +) >= daily_expenses {
                for j in 0..<ETFList.count {
                    allocation_tmp = getDouble(ETFList[j].allocationPercent)
                    portfolioList[j] -= daily_expenses * (allocation_tmp / 100.0)
                    return_tmp = getDouble(ETFList[j].expectedReturn)
                    portfolioList[j] *= getAnnualReturn(return_tmp / 100.0, annual_inflation)
                }
                totalRetiredDays += 1
            }
            remain_to_60 = max(0, days_to_60 - workingDays)
            totalRetiredSuperDays = 0
            portfolio = superGrowth * pow(superGrowthRate, Double(remain_to_60))
            while portfolio >= daily_expenses {
                portfolio -= daily_expenses
                portfolio *= superGrowthRate
                totalRetiredSuperDays += 1
            }
            potential_pre60 = max(1, days_to_60 - workingDays) // avoid /0 when retiring at/after 60
            
            /* Here we calculate sort of like a "gradient" to see which range we should look to proportion
             the financial independence contribution towards brokerage funds or super funds to ensure earliest
             retirement.*/
             
             /* The magnitude of how much brokerage growth is achieved in this epoch compared to the necessary
             (minimum amount) */
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

        return Result(
            workingDays: workingDays,
            retirementDate: retirementDate,
            brokerProp: brokerProp,
            monthlyBrokerContribution: monthlyBroker,
            monthlySuperContribution: monthlySuper,
            brokerageBalanceAtRetirement: brokerageAtRet,
            superBalanceAtRetirement: superAt60
        )
    }

    
    
    
}




#Preview {
    NavigationStack {
        FireResultView()
            .environmentObject(FireInputs())
    }
}

