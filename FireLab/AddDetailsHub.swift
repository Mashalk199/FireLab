//  AddDetailsHub.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct AddDetailsHub: View {
    @EnvironmentObject var inputs: FireInputs
    @State private var showInvestmentSheet = false
    
    var body: some View {
        VStack {
            
            FireLogo()
                .padding([.bottom], 20)
            DateField(
                text: "Date of birth",
                DOB: $inputs.dateOfBirth)
            
            InputField(
                label: "Yearly Non-housing Expenses",
                fieldVar: $inputs.expensesText,
                placeholder: "$")
            
            InputField(
                label: "Yearly FI Contribution",
                fieldVar: $inputs.FIContributionText,
                placeholder: "$")
            
            InputField(
                label: "Assumed Inflation Rate",
                fieldVar: $inputs.inflationRateText,
                placeholder: "%")
            
            InputField(
                label: "Assumed Super After-Tax Growth Rate",
                fieldVar: $inputs.superGrowthRateText,
                placeholder: "%")
            
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
                    InvestmentView()
                }
                .padding(.trailing, 50)
            }
            .sheet(isPresented: $showInvestmentSheet) {
                AddInvestmentView(currETF: SelectedETF())
                    
            }
        }
    }
}

#Preview {
    NavigationStack { AddDetailsHub() }
        .environmentObject(FireInputs())
}
