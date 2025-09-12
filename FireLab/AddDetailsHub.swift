//  AddDetailsHub.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI
import UIKit
/** In this screen, we ask the user to provide their date of birth, yearly non-housing expenses, yearly financial independence (FI/FIRE) contribution, assumed yearly inflation rate and assumed super after-tax growth rate.
 
 There are also 3 buttons, each leading the user to a different screen to provide more details about their financial situation, the 3 buttons leading to housing/mortgage, loan and investment portfolio detail screens.
 */
struct AddDetailsHub: View {
    @EnvironmentObject var inputs: FireInputs
    @State private var showInvestmentSheet = false
    @State private var goNext = false
    @State private var errorText: String?
    @AccessibilityFocusState private var errorFocused: Bool

    /// Function to validate all user inputs
    func validate() -> Bool {
            let cal = Calendar.current
            guard let latest_date_years = cal.date(byAdding: .year, value: -14, to: Date()), inputs.dateOfBirth < latest_date_years else {
                errorText = "You must be at least 14 years and 9 months old to be able to work!"; return false
            }
            // Checks if the current input date is within the last 14 years and 9 months, if it is, the user is too young to earn money
            guard let latest_date = cal.date(byAdding: .month, value: -9, to: latest_date_years), inputs.dateOfBirth < latest_date else {
                errorText = "You must be at least 14 years and 9 months old to be able to work!"; return false
            }
            // Attempts to convert value to double, and adds extra condition to ensure it is greater than 0
            guard let exp = Double(inputs.expensesText), exp > 0 else { errorText = "Enter yearly expenses > 0"; return false }
            guard let cont = Double(inputs.FIContributionText), cont > 0 else { errorText = "Enter contribution > 0"; return false }
            guard let inflationRate = Double(inputs.inflationRateText), inflationRate >= 0, inflationRate <= 100 else { errorText = "Enter 100 >= inflation rate >= 0"; return false }
            guard let superGrowthRate = Double(inputs.superGrowthRateText), superGrowthRate >= 0, superGrowthRate <= 100 else { errorText = "Enter 100 >= super growth rate >= 0"; return false }
            errorText = nil
            return true
        }
    var body: some View {
        VStack {
            
            FireLogo()
                .padding([.bottom], 20)
            // Here we display the error message if it has been set.
            if let msg = errorText {
                Text(msg)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 400, alignment: .center)
                    .padding(.horizontal)
                
                    // Accessibility: mark and focus the error
                    .accessibilityLabel("Error: \(msg)")
                    .accessibilityHint("Fix the fields below, then try again.")
                    // read before other content
                    .accessibilitySortPriority(1000)
                    .accessibilityAddTraits(.isStaticText)
                
                    .accessibilityFocused($errorFocused)
                }
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
                placeholder: "$",
                helpText: "FIRE/FI = Financial Independence. How much will you pay towards all loans and investments, including mortgage.")

            
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
            
            MediumButton(text: "Housing",
                         hint: "Opens housing details page") {
                HousingDetails()
            }
            
            
            MediumButton(text: "Other Loans",
                         hint: "Opens other loans details page") {
                OtherLoanDetails()
            }
            
            MediumButton(text: "Investment Portfolio",
                         hint: "Opens current portfolio details page") {
                PortfolioDetails()
            }
            
            Spacer()
            HStack(spacing: 20) {
                Spacer()
                // Hidden NavigationLink that triggers when goNext flips to true
                Button {
                    if validate() { goNext = true }
                } label: {
                    SmallButtonView(
                        text: "Next", icon: "arrow.right.circle",
                        width: 133, fgColor: .orange, bgColor: .white, border: .black
                    )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 50)
                .accessibilityLabel("Next")
                .accessibilityHint("Opens next page")
            }
            

        }
        .onChange(of: errorText) {
            if let msg = errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
        .navigationDestination(isPresented: $goNext) {
                    InvestmentView()
                }
    }
}

#Preview {
    NavigationStack { AddDetailsHub() }
        .environmentObject(FireInputs())
}
