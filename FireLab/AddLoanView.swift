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
    
    @State private var loanName: String = ""
    @State private var outstandingBalance: String = ""
    @State private var interestRate: String = ""
    @State private var minimumPayment: String = ""
    
    @State private var errorText: String?
    @AccessibilityFocusState private var errorFocused: Bool
    
    //Validates user inputs before creating a loan object.
    private func validate() -> Bool {
        guard !loanName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorText = "Please enter loan name"; return false
        }
        guard let balance = Double(outstandingBalance), balance > 0 else {
            errorText = "Outstanding balance must be > 0"; return false
        }
        guard let rate = Double(interestRate), rate >= 0, rate <= 100 else {
            errorText = "Interest rate must be between 0 and 100"; return false
        }
        guard let minPay = Double(minimumPayment), minPay > 0 else {
            errorText = "Minimum monthly payment must be > 0"; return false
        }
        errorText = nil
        return true
    }
    
    var body: some View {
        VStack {
            FireLogo().padding(.bottom, 20)
            
            //Show error text if validation fails
            if let msg = errorText {
                Text(msg)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityLabel("Error: \(msg)")
                    .accessibilityHint("Fix the fields below, then try again.")
                    .accessibilitySortPriority(1000)
                    .accessibilityFocused($errorFocused)
            }
            
            VStack(spacing: 14) {
                InputField(label: "Loan Name",
                           fieldVar: $loanName,
                           placeholder: "Loan #1")
                
                InputField(label: "Outstanding Balance",
                           fieldVar: $outstandingBalance,
                           placeholder: "$")
                
                InputField(label: "Interest Rate (Yearly)",
                           fieldVar: $interestRate,
                           placeholder: "%")
                
                InputField(label: "Minimum Monthly Payment",
                           fieldVar: $minimumPayment,
                           placeholder: "$")
            }
            .padding(.top, 10)
            
            Spacer()
            
            HStack(spacing: 14) {
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
                    if validate() {
                        inputs.loanItems.append(
                            LoanItem(
                                name: loanName,
                                outstandingBalance: outstandingBalance,
                                interestRate: interestRate,
                                minimumPayment: minimumPayment
                            )
                        )
                        dismiss()
                    }
                } label: {
                    SmallButtonView(
                        text: "Done",
                        icon: "checkmark.circle",
                        width: 140,
                        fgColor: .white,
                        bgColor: .orange,
                        border: .orange
                    )
                }
            }
            .padding(.bottom, 12)
        }
        .onChange(of: errorText) {
            if let msg = errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                errorFocused = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddLoanView()
            .environmentObject(FireInputs())
    }
}
