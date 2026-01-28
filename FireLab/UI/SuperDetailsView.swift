//
//  SuperDetailsView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 20/1/2026.
//

import SwiftUI

struct SuperDetailsView: View {
    @EnvironmentObject var inputs: FireInputs
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var errorFocused: Bool
    @StateObject private var vm = SuperDetailsViewModel()

    var body: some View {
        VStack {
            FireLogo()
                .padding([.bottom], 20)
            
            // Here we display the error message if it has been set.
            FormErrorText(
                message: vm.errorText,
                isFocused: $errorFocused
            )
            
            InputField(label: "Super value",
                       fieldVar: $vm.superValue,
                       placeholder: "$"
            )
            InputField(label: "Super expected return",
                       fieldVar: $vm.superReturn,
                       placeholder: "%"
            )
            InputField(label: "Monthly concessional contributions",
                       fieldVar: $vm.concessional,
                       placeholder: "$ Optional"
            )
            InputField(label: "Monthly non-concessional contributions",
                       fieldVar: $vm.nonConcessional,
                       placeholder: "$ Optional"
            )
            InputField(label: "Retirement spending (% of current expenses)",
                       fieldVar: $vm.retirementMultiplier,
                       placeholder: "% Optional",
                       helpText: "The percentage of your annual expenses you will expect to have in retirement, compared to your working life expenses.",
                       helpPadding: 14
            )
            Spacer()
            
            HStack(spacing: 30) {
                Button {
                    dismiss()
                } label: {
                    SmallButtonView(text: "Cancel",
                                    icon: "arrow.left.circle",
                                    width: 140,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
                .accessibilityLabel("Cancel")

                Button {
                    if vm.validate() {
                        inputs.superannuation = Superannuation(
                            value: vm.superValue,
                            expectedReturn: vm.superReturn,
                            concessional: vm.concessional,
                            nonConcessional: vm.nonConcessional,
                            retirementMultiplier: vm.retirementMultiplier
                        )
                        dismiss()
                    }
                } label: {
                    SmallButtonView(text: "Save",
                                    icon: "checkmark.circle",
                                    width: 140,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
                .accessibilityLabel("Cancel")

            }
        }
        .onAppear { vm.attach(inputs: inputs) } // attach EnvironmentObject

    }
}

#Preview {
    return NavigationStack {
        SuperDetailsView()
    }
    .environmentObject(FireInputs())
}
