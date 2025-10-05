//
//  AddPortfolioItemViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class AddPortfolioItemViewModel: ObservableObject {
    // moved from View now managed by VM
    @Published var tab: PortfolioItemType = .nonSuper
    @Published var investmentName = ""
    @Published var investmentValue = ""
    @Published var investmentReturn = ""   // Yearly interest rate
    @Published var superName = ""
    @Published var superValue = ""
    @Published var errorText: String?

    private var inputs: FireInputs?

    func attach(inputs: FireInputs) {
        if self.inputs == nil { self.inputs = inputs }
    }

    /// Function to validate all user inputs
    func validate() -> Bool {
        switch tab {
        case .nonSuper:
            if investmentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorText = "Enter an investment name"; return false
            }
            guard let value = Double(investmentValue), value > 0 else {
                errorText = "Enter investment value > 0"; return false
            }
            guard let ret = Double(investmentReturn), (0...100).contains(ret) else {
                errorText = "Enter 100 >= yearly investment return rate >= 0"; return false
            }

        case .superannuation:
            if superName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorText = "Enter a superannuation name"; return false
            }
            guard let val = Double(superValue), val > 0 else {
                errorText = "Enter super value > 0"; return false
            }
        }

        errorText = nil
        return true
    }

    /// Append to inputs if valid. Returns true if added so the View can dismiss.
    func addIfValid() -> Bool {
        guard validate(), let inputs else { return false }

        switch tab {
        case .nonSuper:
            inputs.portfolioItems.append(
                PortfolioItem(
                    name: investmentName,
                    // By default, set any non-super investments to ETF type
                    type: .etf,
                    value: investmentValue,
                    expectedReturn: investmentReturn
                )
            )

        case .superannuation:
            inputs.portfolioItems.append(
                PortfolioItem(
                    name: superName,
                    type: .superannuation,
                    value: superValue,
                    expectedReturn: inputs.superGrowthRateText   // not collected for super in current UI
                )
            )
        }

        return true
    }

    // moved enum here from View
    enum PortfolioItemType: String {
        case nonSuper, superannuation
    }
}
