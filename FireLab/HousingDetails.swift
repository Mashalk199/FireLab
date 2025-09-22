//
//  HousingDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI

struct HousingDetails: View {
    @EnvironmentObject var inputs: FireInputs
    @State private var tab = HousingType.mortgage
    
    @State private var errorText: String?
    
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var errorFocused: Bool
    
    /// Function to validate all user inputs
    private func validate() -> Bool {
            
        if tab == .mortgage {
            guard let outstanding = Double(inputs.outstandingMortgageText), outstanding > 0
            else { errorText = "Enter outstanding mortgage balance > 0"; return false }
            
            guard let mortgageYearlyInterest = Double(inputs.mortgageYearlyInterestText), mortgageYearlyInterest >= 0, mortgageYearlyInterest <= 100
            else {
                errorText = "Enter 100 >= yearly mortgage interest rate >= 0";
                return false }
            
            guard let mortgageMinimumPayment = Double(inputs.mortgageMinimumPaymentText), mortgageMinimumPayment > 0
            else {
                errorText = "Enter minimum monthly payment > 0";
                return false }
        }
        else if tab == .rent {
            guard let weeklyRent = Double(inputs.weeklyRentText), weeklyRent >= 0
            else {
                errorText = "Enter weekly rent >= 0";
                return false }
        }
        
        errorText = nil
        return true
    }
    
    var body: some View {
        VStack {
            FireLogo()
                .padding([.bottom], 20)
            
                .navigationBarBackButtonHidden(true)
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
            
            Text("Are you renting or do you have a mortgage?")
            
            Picker("Housing type", selection: $tab) {
                
                Text("Mortgage").tag(HousingType.mortgage)
                    .accessibilityLabel("Mortgage")
                    .accessibilityHint("Select to enter details about your mortgage")
                
                Text("Rent").tag(HousingType.rent)
                    .accessibilityLabel("Rent")
                    .accessibilityHint("Select to enter details about your rental house")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .accessibilityLabel("Select housing type")
            
            VStack(spacing: 14) {
                // If housing type is either mortgage or rent, display the appropriate input fields
                if tab == .mortgage {
                    InputField(label: "Outstanding Mortgage Balance",
                               fieldVar: $inputs.outstandingMortgageText,
                               placeholder: "$",
                    )
                    .padding(.top, 15)
                    
                    InputField(label: "Mortgage Yearly Interest Rate",
                               fieldVar: $inputs.mortgageYearlyInterestText,
                               placeholder: "%",
                    )
                    
                    InputField(label: "Mortgage Minimum Monthly Payment",
                               fieldVar: $inputs.mortgageMinimumPaymentText,
                               placeholder: "$",
                    )
                    
                }
                else if tab == .rent {
                    InputField(label: "Weekly Rent",
                               fieldVar: $inputs.weeklyRentText,
                               placeholder: "$",
                    )
                    .padding(.top, 15)
                    
                }
            }
            
            Spacer()
            HStack(spacing: 14) {
                Button {
                    inputs.housingDetailsSet = .unset
                    dismiss()
                }
                label: {
                    SmallButtonView(
                        text: "Cancel", icon: "arrow.left.circle",
                        width: 140, fgColor: .orange, bgColor: .white, border: .black
                    )
                }
                Button {
                    if validate() {
                        inputs.housingDetailsSet = .set
                        dismiss()
                    }
                } label: {
                    SmallButtonView(
                        text: "Done", icon: "checkmark.circle", width: 140, fgColor: .white, bgColor: .orange, border: .orange
                    )
                }
            }
        }
        .onChange(of: errorText) {
            if let msg = errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
        
    }
    
    private enum HousingType: String {
        case mortgage, rent
    }
     
}
enum HousingDetailsSet: String {
   case unset, set
}

#Preview {
    NavigationStack { HousingDetails() }
        .environmentObject(FireInputs())
}
