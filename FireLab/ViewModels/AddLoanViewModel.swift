//
//  AddLoanViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class AddLoanViewModel: ObservableObject {

    let currItem: LoanItem
    
    // moved from View
    @Published var loanName: String = ""
    @Published var outstandingBalance: String = ""
    @Published var yearlyInterest: String = ""
    @Published var minimumPayment: String = ""
    @Published var errorText: String?

    private var inputs: FireInputs?
    
    init(currItem: LoanItem) {
        self.currItem = currItem
        // If editing an existing item, prefill the fields
        self.loanName = currItem.name
        self.outstandingBalance = currItem.outstandingBalance
        self.yearlyInterest = currItem.interestRate
        self.minimumPayment = currItem.minimumPayment
    }

    func attach(inputs: FireInputs) {
        if self.inputs == nil { self.inputs = inputs }
    }

    /// Function to validate all user inputs
    func validate() -> Bool {
        if loanName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorText = "Enter a loan name"
            return false
        }

        guard let balance = Double(outstandingBalance), balance > 0 else {
            errorText = "Enter outstanding balance > 100"
            return false
        }

        guard let rate = Double(yearlyInterest), (0...100).contains(rate) else {
            errorText = "Enter 100 >= yearly loan interest rate >= 0"
            return false
        }

        guard let minPay = Double(minimumPayment), minPay > 0 else {
            errorText = "Enter minimum monthly payment > 0"
            return false
        }

        errorText = nil
        return true
    }

    /// Append to inputs if valid. Returns true if added so the View can dismiss.
    func addIfValid() -> Bool {
        guard validate(), let inputs else { return false }

        if let idx = inputs.loanItems.firstIndex(where: { $0.id == currItem.id }) {

            // Update existing item in place
            inputs.loanItems[idx].name = loanName
            inputs.loanItems[idx].outstandingBalance = outstandingBalance
            inputs.loanItems[idx].interestRate = yearlyInterest
            inputs.loanItems[idx].minimumPayment = minimumPayment

        }
        else {
            inputs.loanItems.append(
                LoanItem(
                    name: loanName,
                    outstandingBalance: outstandingBalance,
                    interestRate: yearlyInterest,
                    minimumPayment: minimumPayment
                )
            )
        }
        return true
    }
}
