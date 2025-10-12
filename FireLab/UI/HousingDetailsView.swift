//
//  HousingDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI
/**
 This screen displays an interface for a user to enter their housing details, whether it be rental or mortgage details.
 */
struct HousingDetailsView: View {
    @EnvironmentObject var inputs: FireInputs
    @StateObject private var vm = HousingDetailsViewModel()

    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var errorFocused: Bool
    
    var body: some View {
        VStack {
            FireLogo()
                .padding([.bottom], 20)
                .navigationBarBackButtonHidden(true)

            // Here we display the error message if it has been set.
            if let msg = vm.errorText {
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
            
            Picker("Housing type", selection: $inputs.housingType) {
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
                if inputs.housingType == .mortgage {
                    InputField(label: "Outstanding Mortgage Balance",
                               fieldVar: $inputs.outstandingMortgageText,
                               placeholder: "$")
                    .padding(.top, 15)
                    
                    InputField(label: "Mortgage Yearly Interest Rate",
                               fieldVar: $inputs.mortgageYearlyInterestText,
                               placeholder: "%")
                    
                    InputField(label: "Mortgage Minimum Monthly Payment",
                               fieldVar: $inputs.mortgageMinimumPaymentText,
                               placeholder: "$")
                }
                else if inputs.housingType == .rent {
                    InputField(label: "Weekly Rent",
                               fieldVar: $inputs.weeklyRentText,
                               placeholder: "$")
                    .padding(.top, 15)
                }
            }
            
            Spacer()
            HStack(spacing: 14) {
                Button {
                    dismiss()
                } label: {
                    SmallButtonView(
                        text: "Cancel", icon: "arrow.left.circle",
                        width: 140, fgColor: .orange, bgColor: .white, border: .black
                    )
                }
                Button {
                    if vm.validate() {
                        inputs.housingDetailsSet = .set
                        dismiss()
                    }
                } label: {
                    SmallButtonView(
                        text: "Done", icon: "checkmark.circle",
                        width: 140, fgColor: .white, bgColor: .orange, border: .orange
                    )
                }
            }
        }
        .onAppear { vm.attach(inputs: inputs) }
        .onChange(of: vm.errorText) {
            if let msg = vm.errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
    }
}

#Preview {
    NavigationStack { HousingDetailsView() }
        .environmentObject(FireInputs())
}
