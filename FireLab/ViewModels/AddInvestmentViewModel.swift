//
//  AddInvestmentViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class AddInvestmentViewModel: ObservableObject {
    // moved from View
    @Published var tab: Int = 0   // 0: ETF, 1: Bond
    @Published var name = ""
    @Published var expected = ""
    @Published var autoCalc = false
    @Published var errorText: String?

    let currETF: SelectedETF
    private var inputs: FireInputs?

    init(currETF: SelectedETF) {
        self.currETF = currETF
    }

    func attach(inputs: FireInputs) {
        if self.inputs == nil { self.inputs = inputs }
    }

    /// Function to validate user input, ensuring an ETF is selected or that a bond name is set
    func validate() -> Bool {
        if tab == 0 {
            guard currETF.selectedETF != nil else {
                errorText = "Please select an ETF"
                return false
            }
        } else {
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorText = "Please create a bond name"
                return false
            }
        }

        guard let expectedETFReturn = Double(expected),
              expectedETFReturn <= 100, expectedETFReturn > 0 else {
            errorText = "Enter 100 >= Expected Return > 0"
            return false
        }

        errorText = nil
        return true
    }

    /// Adds to inputs if valid; returns true so the View can dismiss.
    func addInvestmentIfValid() -> Bool {
        guard validate(), let inputs else { return false }

        let displayName = tab == 0
        ? (currETF.selectedETF?.name ?? "ETF")
        : (name.isEmpty ? "Bond #1" : name)

        inputs.investmentItems.append(
            InvestmentItem(
                name: displayName,
                type: tab == 0 ? .etf : .bond,
                allocationPercent: "",
                expectedReturn: expected
            )
        )

        currETF.selectedETF = nil
        return true
    }
}
