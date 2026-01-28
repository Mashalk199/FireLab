//
//  IncomeDetailsView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 27/1/2026.
//

import SwiftUI

struct IncomeDetailsView: View {
    @EnvironmentObject var inputs: FireInputs
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var errorFocused: Bool
    @StateObject private var vm = IncomeDetailsViewModel()

    var body: some View {
        VStack {
            FireLogo()
                .padding(.bottom, 20)
            
            Text("Used to estimate your take-home pay and super contributions.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .padding(.horizontal)
            
            FormErrorText(
                message: vm.errorText,
                isFocused: $errorFocused
            )

            InputField(
                label: "Annual salary",
                fieldVar: $vm.salary,
                placeholder: "$"
            )

            InputField(
                label: "Other taxable income",
                fieldVar: $vm.otherIncome,
                placeholder: "$ Optional",
                helpText: "Bonuses, side income, freelance work, etc."
            )

            Toggle(isOn: $vm.hasPrivateHealthCover) {
                Text("Private hospital cover")
            }
            .padding(.horizontal)
            .accessibilityLabel("Private hospital cover")
            .accessibilityHint("Used to determine Medicare levy surcharge")

            Spacer()

            HStack(spacing: 30) {
                Button {
                    dismiss()
                } label: {
                    SmallButtonView(
                        text: "Cancel",
                        icon: "arrow.left.circle",
                        width: 140,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black
                    )
                }

                Button {
                    if vm.validate() {
                        inputs.employment = Employment(
                            yearlyIncome: vm.salary,
                            otherIncome: vm.otherIncome,
                            hasPrivateHealthCover: vm.hasPrivateHealthCover
                        )
                        dismiss()
                    }
                } label: {
                    SmallButtonView(
                        text: "Save",
                        icon: "checkmark.circle",
                        width: 140,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black
                    )
                }
            }
        }
        .onAppear { vm.attach(inputs: inputs) }
    }
}

#Preview {
    NavigationStack {
        IncomeDetailsView()
    }
    .environmentObject(FireInputs())
}
