//
//  AddLoanView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 23/9/2025.
//

import SwiftUI

struct AddLoanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs
    @State var loanName: String = ""
    @State var outstandingBalance: String = ""
    @State var yearlyInterest: String = ""
    @State var minimumPayment: String = ""
    @State private var errorText: String?

    @AccessibilityFocusState private var errorFocused: Bool
    
    /// Function to validate all user inputs
    private func validate() -> Bool {
            
        if loanName.isEmpty {
            errorText = "Enter a loan name"
            return false
        }
        
            
        guard let outstandingBalanceField = Double(outstandingBalance), outstandingBalanceField > 0
        else {
            errorText = "Enter outstanding balance > 100";
            return false
        }
            
        guard let yearlyInterestField = Double(yearlyInterest), yearlyInterestField >= 0, yearlyInterestField <= 100
        else {
            errorText = "Enter 100 >= yearly loan interest rate >= 0";
            return false }
        
        guard let minimumPaymentField = Double(minimumPayment), minimumPaymentField > 0
        else {
            errorText = "Enter minimum monthly payment > 0";
            return false
        }
        errorText = nil
        return true
    }
    var body: some View {
            FireLogo()
                .padding([.bottom], 20)
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
        VStack {
            InputField(
                label: "Loan Name",
                fieldVar: $loanName,
                placeholder: "Name",
            )
            InputField(
                label: "Outstanding loan balance",
                fieldVar: $outstandingBalance,
                placeholder: "$",
            )
            InputField(
                label: "Yearly interest rate",
                fieldVar: $yearlyInterest,
                placeholder: "%",
            )
            InputField(
                label: "Minimum monthly payment",
                fieldVar: $minimumPayment,
                placeholder: "$",
            )
            Spacer()
            HStack(spacing: 14) {
                Button {
                    dismiss()
                } label: {
                    SmallButtonView(text: "Cancel",
                                    icon: "arrow.left.circle",
                                    width: 150,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
                .accessibilityLabel("Cancel adding loan")
                
                Button {
                    if validate() {
                        inputs.loanItems.append(
                            LoanItem(name: loanName,
                                     outstandingBalance: outstandingBalance,
                                     interestRate: yearlyInterest,
                                     minimumPayment: minimumPayment)
                        )
                        dismiss()
                    }
                } label: {
                    SmallButtonView(text: "Add",
                                    icon: "checkmark.circle",
                                    width: 133,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
                .accessibilityLabel("Add loan")
                .accessibilityHint("Add loan to your finances")

                
            }
        }
        .onChange(of: errorText) {
            if let msg = errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
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
