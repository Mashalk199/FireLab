//
//  InvestmentPortfolioDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI

/*struct PortfolioDetails: View {
    var body: some View {
        Text("Portfolio tracking coming out soon...")
    }
}*/


import SwiftUI



struct PortfolioDetails: View {
    @EnvironmentObject var inputs: FireInputs
    
    var body: some View {
        VStack {
            Text("Portfolio")
                .font(.title).bold()
                .padding(.bottom, 8)
            
            if inputs.items.isEmpty {
                Text("Calculations for portfolios are coming out soon...")
                    .foregroundStyle(.secondary)
            } else {
                List(inputs.items) { it in
                    HStack {
                        Text(it.name)
                        Spacer()
                        Text(it.allocationPercent.isEmpty ? "-" : "\(it.allocationPercent)%")
                            .foregroundStyle(.secondary)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle("Portfolio")
    }
}

#Preview("Portfolio") {
    let inputs = FireInputs()
    inputs.items = [
        InvestmentItem(name: "VDHG", type: .etf, allocationPercent: "60"),
        InvestmentItem(name: "AusGov Bonds", type: .bond, allocationPercent: "40")
    ]
    return NavigationStack { PortfolioDetails() }
        .environmentObject(inputs)
}
