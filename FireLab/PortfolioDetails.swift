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

enum InvestmentType: String, Codable { case etf, bond }

struct InvestmentItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var type: InvestmentType
    var allocationPercent: String = ""
    var amount: String = ""
    var expectedReturn: String = ""
    
    private enum CodingKeys: String, CodingKey {
           case name, type, allocationPercent, amount, expectedReturn
       }
}

final class PortfolioModel: ObservableObject {
    @Published var items: [InvestmentItem] = []
}

struct PortfolioDetails: View {
    @EnvironmentObject var app: AppModel
    
    var body: some View {
        VStack {
            Text("Portfolio")
                .font(.title).bold()
                .padding(.bottom, 8)
            
            if app.portfolio.items.isEmpty {
                Text("Calculations for investment coming out soon...")
                    .foregroundStyle(.secondary)
            } else {
                List(app.portfolio.items) { it in
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
    let app = AppModel()
    app.portfolio.items = [
        InvestmentItem(name: "VDHG", type: .etf, allocationPercent: "60"),
        InvestmentItem(name: "AusGov Bonds", type: .bond, allocationPercent: "40")
    ]
    return NavigationStack { PortfolioDetails() }
        .environmentObject(app)
}
