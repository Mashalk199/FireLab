//
//  AddLoanView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 23/9/2025.
//

import SwiftUI
///This SwiftUI view allows the user to add details of a new loan It collects inputs such as loan name, outstanding balance, yearly interest rate, and minimum monthly payment.

struct AddLoanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs

    @StateObject private var vm = AddLoanViewModel()
    @AccessibilityFocusState private var errorFocused: Bool

    var body: some View {
        FireLogo()
            .padding([.bottom], 20)

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

        VStack {
            InputField(
                label: "Loan Name",
                fieldVar: $vm.loanName,
                placeholder: "Name"
            )
            InputField(
                label: "Outstanding loan balance",
                fieldVar: $vm.outstandingBalance,
                placeholder: "$"
            )
            InputField(
                label: "Yearly interest rate",
                fieldVar: $vm.yearlyInterest,
                placeholder: "%"
            )
            InputField(
                label: "Minimum monthly payment",
                fieldVar: $vm.minimumPayment,
                placeholder: "$"
            )

            Spacer()

            HStack(spacing: 14) {
                Button {
                    dismiss()
                } label: {
                    SmallButtonView(
                        text: "Cancel",
                        icon: "arrow.left.circle",
                        width: 150,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black
                    )
                }
                .accessibilityLabel("Cancel adding loan")

                Button {
                    if vm.addIfValid() {
                        dismiss()
                    } else {
                        errorFocused = true
                    }
                } label: {
                    SmallButtonView(
                        text: "Add",
                        icon: "checkmark.circle",
                        width: 133,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black
                    )
                }
                .accessibilityLabel("Add loan")
                .accessibilityHint("Add loan to your finances")
            }
        }
        // attach EnvironmentObject after the view exists
        .onAppear { vm.attach(inputs: inputs) }
        .onChange(of: vm.errorText) { _, new in
            if let msg = new {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                errorFocused = true
            }
        }

        Spacer()
    }
}

#Preview {
    NavigationStack {
        AddLoanView()
            .environmentObject(FireInputs())
    }
}
