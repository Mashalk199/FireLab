//
//  AddInvestmentViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation
import SwiftUI
@MainActor
final class AddInvestmentViewModel: ObservableObject {
    // moved from View
    @Published var tab: Int = 0   // 0: ETF, 1: Bond
    @Published var bondName = ""
    @Published var expectedBondRet = ""
    @Published var expectedEtfRet = ""
    @Published var autoCalc = false
    @Published var errorText: String?
    

    var currETF: SelectedETF
    let editItem: InvestmentItem?

    private var inputs: FireInputs?

    init(currETF: SelectedETF, editItem: InvestmentItem?) {
        self.currETF = currETF
        self.editItem = editItem
        
        /* Below the item-to-edit's values are prefilled, otherwise if
        it doesn't exist then default values are used */
        if self.editItem?.type == .etf {
            self.tab = 0
            self.expectedEtfRet = self.editItem?.expectedReturn ?? ""

        }
        else if self.editItem?.type == .bond {
            self.tab = 1
            self.expectedBondRet = self.editItem?.expectedReturn ?? ""
            self.bondName = self.editItem?.name ?? ""

        }
        self.autoCalc = self.editItem?.autoCalc ?? false
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
            guard let expectedETFReturn = Double(expectedEtfRet),
                  expectedETFReturn <= 100, expectedETFReturn > 0 else {
                errorText = "Enter 100 >= Expected Return > 0"
                return false
            }
        } else {
            if bondName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorText = "Please create a bond name"
                return false
            }
            guard let expectedBondReturn = Double(expectedBondRet),
                  expectedBondReturn <= 100, expectedBondReturn > 0 else {
                errorText = "Enter 100 >= Expected Return > 0"
                return false
            }
        }

        

        errorText = nil
        return true
    }

    /// Adds to inputs if valid; returns true so the View can dismiss.
    func addInvestmentIfValid() -> Bool {
        guard validate(), let inputs else { return false }

        let displayName = tab == 0
            ? (currETF.selectedETF?.name ?? "ETF")
            : (bondName.isEmpty ? "Bond #1" : bondName)

        let snapshot = (tab == 0) ? currETF.selectedETF : nil

        if let editItem, let idx = inputs.investmentItems.firstIndex(where: { $0.id == editItem.id }) {

                // Update existing item in place
                inputs.investmentItems[idx].name = displayName
                inputs.investmentItems[idx].type = (tab == 0 ? .etf : .bond)
                inputs.investmentItems[idx].expectedReturn = (tab == 0 ? expectedEtfRet : expectedBondRet)
                inputs.investmentItems[idx].etfSnapshot = snapshot
                inputs.investmentItems[idx].autoCalc = autoCalc

        }
        else {
            inputs.investmentItems.append(
                InvestmentItem(
                    name: displayName,
                    type: tab == 0 ? .etf : .bond,
                    allocationPercent: "",
                    expectedReturn: tab == 0 ? expectedEtfRet : expectedBondRet,
                    etfSnapshot: snapshot,
                    autoCalc: autoCalc
                )
            )
        }

        currETF.selectedETF = nil
        return true
    }
}
