//  AddDetailsHub.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct AddDetailsHub: View {
    @EnvironmentObject var inputs: FireInputs
    @EnvironmentObject var portfolio: PortfolioModel
    @State private var showInvestmentSheet = false
    
    var body: some View {
        VStack {
            
            Logo()
                .padding([.bottom], 20)
            
            InputField(
                label: "Yearly Income",
                fieldVar: $inputs.yearlyIncomeText,
                placeholder: "$")
            
            InputField(
                label: "Yearly Non-housing Expenses",
                fieldVar: $inputs.nonHousingText,
                placeholder: "$")
            
            InputField(
                label: "Monthly FI Contribution",
                fieldVar: $inputs.FIContributionText,
                placeholder: "$")
            
            Text("Add details:")
                .padding(.top, 20)
            
            MediumButton(text: "Housing") {
                HousingDetails()
            }
            
            MediumButton(text: "Other Loans") {
                OtherLoanDetails()
            }
            
            MediumButton(text: "Investment Portfolio") {
                PortfolioDetails()
            }
            
            
            
            
            Spacer()
            HStack(spacing: 20) {
                Spacer()
                SmallButton(text: "Next",
                            icon: "arrow.right.circle",
                            width: 133,
                            fgColor: Color.orange,
                            bgColor: Color.white,
                            border: Color.black) {
                    InvestmentAllocatorView()
                }
                            .padding(.trailing, 50)
            }
            .sheet(isPresented: $showInvestmentSheet) {
                AddInvestmentView()
                    .environmentObject(portfolio)
            }
        }
    }
}

#Preview {
    let inputs = FireInputs()
    let portfolio = PortfolioModel()
    return NavigationStack {
        AddDetailsHub()
    }
    .environmentObject(inputs)
    .environmentObject(portfolio)
}
