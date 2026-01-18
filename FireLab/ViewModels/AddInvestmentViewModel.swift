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
    @Published var superName = ""
    @Published var expectedBondRet = ""
    @Published var expectedEtfRet = ""
    @Published var autoCalc = false
    @Published var errorText: String?
    @Published var currentValue = ""
    @Published var ownsCurrently: Bool = true


    let currItem: InvestmentItem

    private var inputs: FireInputs?

    init(currItem: InvestmentItem) {
        self.currItem = currItem
        
        /* Below the item-to-edit's values are prefilled, otherwise if
        it doesn't exist then default values are used */
        if self.currItem.type == .etf {
            self.tab = 0
            self.expectedEtfRet = self.currItem.expectedReturn

        }
        else if self.currItem.type == .bond {
            self.tab = 1
            self.expectedBondRet = self.currItem.expectedReturn
            self.bondName = self.currItem.name

        }
        else if self.currItem.type == .superannuation {
            self.tab = 2
            self.expectedBondRet = self.currItem.expectedReturn
            self.bondName = self.currItem.name
        }
        self.autoCalc = self.currItem.autoCalc
        
        self.currentValue = currItem.currentValue
        self.ownsCurrently = !self.currentValue.isEmpty
    }

    func attach(inputs: FireInputs) {
        if self.inputs == nil { self.inputs = inputs }
    }

    /// Function to validate user input, ensuring an ETF is selected or that a bond name is set
    func validate(currItem: InvestmentItem) -> Bool {
        if tab == 0 {
            guard currItem.etfSnapshot != nil else {
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
        if ownsCurrently {
            guard let currValue = Double(currentValue), currValue >= 0 else {
                errorText = "Enter current value >= 0"
                return false
            }
            
        }

        

        errorText = nil
        return true
    }

    /// Adds to inputs if valid; returns true so the View can dismiss.
    func addInvestmentIfValid(currItem: InvestmentItem) -> Bool {
        guard validate(currItem: currItem), let inputs else { return false }

        let displayName = tab == 0
        ? (currItem.etfSnapshot?.name ?? "ETF")
            : (bondName.isEmpty ? "Bond #1" : bondName)

        let snapshot = (tab == 0) ? currItem.etfSnapshot : nil

        if let idx = inputs.investmentItems.firstIndex(where: { $0.id == currItem.id }) {

                // Update existing item in place
                inputs.investmentItems[idx].name = displayName
                inputs.investmentItems[idx].type = (tab == 0 ? .etf : .bond)
                inputs.investmentItems[idx].expectedReturn = (tab == 0 ? expectedEtfRet : expectedBondRet)
                inputs.investmentItems[idx].etfSnapshot = snapshot
                inputs.investmentItems[idx].autoCalc = autoCalc
                inputs.investmentItems[idx].currentValue =
                    ownsCurrently ? self.currentValue : ""
        }
        else {
            inputs.investmentItems.append(
                InvestmentItem(
                    name: displayName,
                    type: tab == 0 ? .etf : .bond,
                    allocationPercent: "",
                    expectedReturn: tab == 0 ? expectedEtfRet : expectedBondRet,
                    currentValue: ownsCurrently ? self.currentValue : "",
                    etfSnapshot: snapshot,
                    autoCalc: autoCalc
                )
            )
        }
        return true
    }
}
