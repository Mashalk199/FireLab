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

    
    var years: Int = 22
    var months: Int = 4
    var portfolioTarget: String = "1,634,780.93"

    var body: some View {
        VStack(spacing: 20) {
            Logo().padding(.top, 8)

            Text("\(years) years")
                .font(.system(size: 44, weight: .bold))
                .padding(.top, 10)
            Text("\(months) Months\nuntil you reach financial independence")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text("Your portfolio will reach")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            Text("$\(portfolioTarget)")
                .font(.system(size: 34, weight: .black))

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
    
    func getAnnualReturn(_ percentage: Double,_ annual_inflation: Double) -> Double {
        return pow(((1.0 + percentage) / (1.0 + annual_inflation)), (1.0/365.0))
    }
    func getProps(_ proportion: Double) -> (Double, Double) {
        return (proportion, 1.0 - proportion)
        // Usage - tuple destructuring (most Python-like)
        //let (original, complement) = getProps(0.3)
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
    func calculateRetirement() -> Double {
        var daily_expenses: Double = getDouble(inputs.expensesText)
        daily_expenses /= 365
        var dailyFiCont: Double = getDouble(inputs.FIContributionText)
        ?? 100
        var age_in_days: Int = daysBetween(inputs.dateOfBirth, Date())
        var portfolio: Double = 0
        var superGrowth: Double = 0
        var retiredBroker = false
        var retiredSuper = false
        var workingDays: Int = 0
        var retiredDays: Int = 0
        var ETFList = inputs.items
        
        var days_during_super = 7 * 365
        guard let d60 = Calendar.current.date(byAdding: .year, value: 60, to: inputs.dateOfBirth),
              let d67 = Calendar.current.date(byAdding: .year, value: 67, to: inputs.dateOfBirth) else {
            return 0
        }
        let days_to_60 = daysBetween(Date(), d60)
        let days_to_67 = daysBetween(Date(), d67)

        var (brokerProp, superProp): (Double, Double) = getProps(0.5)
        var (brokerCont, superCont): (Double, Double) = (0, 0)
        var (prevProp, initialProp): (Double, Double) = (0, 0)
        var (minProp, maxProp): (Double, Double) = (0, 1)

        var brokerListGrowth: [Double] = []
        var final_pre60_days: Int? = nil
        var final_post60_days: Int? = nil
        
        var allocation_tmp: Double = 0
        var return_tmp: Double = 0

        // 12 epochs is more than enough to perform an adequate binary search
        for i in 1...12 {
            brokerListGrowth = Array(repeating: 0, count: ETFList.count)
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
                    brokerListGrowth[j] += brokerCont * (allocation_tmp / 100)
                    brokerListGrowth[j] *= getAnnualReturn(getDouble(ETFList[j].expectedReturn) / 100,
                                                           getDouble(inputs.inflationRateText))
                }
                // Grow super by 1 day of investments
                superGrowth += superCont
                superGrowth *= getDouble(inputs.superGrowthRateText)
                
            }

        }


        
        
        return 0
    }

    
    
    
}




#Preview {
    NavigationStack {
        FireResultView()
            .environmentObject(FireInputs())
    }
}

