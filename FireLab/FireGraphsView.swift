//
//  FireGraphsView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI
import Charts
struct PetData: Identifiable {
    let id = UUID()
    var year: Int
    var population: Double
}

struct SamplePoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
struct FireGraphsView: View {
    @ObservedObject var retirementData: RetirementData
    var currentDate = Date()
    var x_years: [String] = []
    // Stable base date so previews don't shift every recompute
    private let baseDate = ISO8601DateFormatter().date(from: "2025-01-01T00:00:00Z")!
    //TODO: make this date dynamic
        //Maybe set the date to midnight of the CURRENT day

    var brokerageGrowthSeries: [SamplePoint] {
        let cal = Calendar.current
        return retirementData.brokerageGrowthData.enumerated().compactMap { i, v in
            guard let date = cal.date(byAdding: .day, value: i, to: baseDate) else { return nil }
            return SamplePoint(date: date, value: v)
        }
    }

    var body: some View {
        
        VStack(spacing: 16) {
            FireLogo().padding(.top, 8)
            
            
            let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.accentColor.opacity(0.4),
                Color.accentColor.opacity(0)]),
                startPoint: .top, endPoint: .bottom)
            Chart {
                ForEach(brokerageGrowthSeries) { data in
                    LineMark(x: .value("Date", data.date),
                             y: .value("Value", data.value))
                }
                .interpolationMethod(.cardinal)
//                .symbol(by: .value("Investment type", "Brokerage"))
                
                ForEach(brokerageGrowthSeries) { data in
                    AreaMark(x: .value("Date", data.date),
                             y: .value("Value", data.value))
                }
                .interpolationMethod(.cardinal)
                .foregroundStyle(linearGradient)

            }
//            .chartXScale(domain: 1998...2024)
            .chartLegend(.hidden)

            .aspectRatio(1, contentMode: .fit)
            .padding()
            Spacer()

                }
        
    }
    
    
    
}
#Preview {
    var retirementData = RetirementData()
    retirementData.brokerageGrowthData = [1, 2, 3, 4, 5, 4, 3 ,2, 1]
    return NavigationStack {
        FireGraphsView(retirementData: retirementData)
    }
        .environmentObject(FireInputs())
}
