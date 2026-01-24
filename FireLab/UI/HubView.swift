//  HubView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

/** In this screen, we ask the user to provide their date of birth, yearly non-housing expenses, yearly financial independence (FI/FIRE) contribution, assumed yearly inflation rate and assumed super after-tax growth rate.
 
 There are also 3 buttons, each leading the user to a different screen to provide more details about their financial situation, the 3 buttons leading to housing/mortgage, loan and investment portfolio detail screens.
 */
struct HubView: View {
    @EnvironmentObject var inputs: FireInputs
    @StateObject private var vm = HubViewModel()
    @State private var goNext = false
    @AccessibilityFocusState private var errorFocused: Bool
    var body: some View {
        VStack {
            
            FireLogo()
                .padding([.bottom], 20)
            
            FormErrorText(
                message: vm.errorText,
                isFocused: $errorFocused
            )
            
            DateField(
                text: "Date of birth",
                DOB: $inputs.dateOfBirth)
            
            InputField(
                label: "Yearly non-loan expenses",
                fieldVar: $inputs.expensesText,
                placeholder: "$")

            
            InputField(
                label: "Yearly FI Contribution",
                fieldVar: $inputs.FIContributionText,
                placeholder: "$",
                helpText: "FIRE/FI = Financial Independence. FI contribution is how much will you pay towards all loans and investments.")

            
            InputField(
                label: "Assumed inflation rate",
                fieldVar: $inputs.inflationRateText,
                placeholder: "%")
            
            
            MediumButton(text: "Add Loans",
                         hint: "Opens other loans details page") {
                LoanDetailsView()
            }
            MediumButton(text: "Superannuation",
                         hint: "Opens superannuation details page") {
                SuperDetailsView()
            }
            
            Spacer()
            HStack(spacing: 20) {
                Spacer()
                // Hidden NavigationLink that triggers when goNext flips to true
                Button {
                    if vm.validate() { goNext = true }
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
        .onChange(of: vm.errorText) {
            if let msg = vm.errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
        // We attach fireinputs to the viewmodel once the current view has mounted and gains access to the object
        .onAppear {
            vm.attach(inputs: inputs)
            // Clears the error message when we come back to this screen
            vm.errorText = nil
}
        .navigationDestination(isPresented: $goNext) {
                    InvestmentView()
                }
    }
}

#Preview {
    NavigationStack { HubView() }
        .environmentObject(FireInputs())
}
