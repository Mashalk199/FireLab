//
//  InvestmentViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class InvestmentViewModel: ObservableObject {
    @Published var errorText: String?
    
    // gets attached from the View (so EnvironmentObject is available first)
    private var inputs: FireInputs?
    func attach(inputs: FireInputs) { if self.inputs == nil { self.inputs = inputs } }
    
    /// This computed property computes the total percentage allocated by the user across all investments displayed.
    var totalPercent: Double {
        guard let inputs else { return 0 }
        return inputs.investmentItems
            .map { Double($0.allocationPercent.trimmingCharacters(in: .whitespaces)) ?? 0 }
            .reduce(0, +)
    }

    /// Computed property that checks whether the list of investments is not empty and that the total allocated percentages add up to near 100%.
    var canCalculate: Bool {
        guard let inputs, !inputs.investmentItems.isEmpty else { return false }
        return abs(totalPercent - 100) < 0.01
    }
    
    // Function to validate all user inputs moved from View
    func validate() -> Bool {
        guard let inputs else { return false }
        if !canCalculate {
            errorText = "Please ensure total allocation percentages sum to 100%"
            return false
        }
        // Ensures there are no empty boxes for allocation percentages
        for item in inputs.investmentItems {
            if let _ = Double(item.allocationPercent.trimmingCharacters(in: .whitespaces)) {
                continue
            }
            errorText = "Please enter valid percentage allocations"
            return false
        }
        errorText = nil
        return true
    }
    
    /// Autocompletes all unfilled allocations with an equal allocation. moved from View
    func autocompleteAllocations() {
        guard let inputs, !inputs.investmentItems.isEmpty else { return }
        let filledTotal = inputs.investmentItems
                .compactMap { Double($0.allocationPercent.trimmingCharacters(in: .whitespaces)) }
                .reduce(0, +)

        // Filter indices for all investment items which don't have an allocation entered
        let emptyIdxs = inputs.investmentItems.indices.filter {
            inputs.investmentItems[$0].allocationPercent.trimmingCharacters(in: .whitespaces).isEmpty
        }

        // If nothing to fill or no room left, exit
        guard !emptyIdxs.isEmpty else { return }
        
        let remaining = max(0, 100.0 - filledTotal)
        // If the total proportion assigned is higher than 100%, no autocomplete happens
        guard remaining > 0 else { return }
        let even = remaining / Double(emptyIdxs.count)
        // Assign evenly (1 decimal), last one gets the remainder to reach 100.0
        var allocated = 0.0
        for (pos, idx) in emptyIdxs.enumerated() {
            if pos < emptyIdxs.count - 1 {
                let v = (even * 10).rounded() / 10
                inputs.investmentItems[idx].allocationPercent = String(format: "%.1f", v)
                allocated += v
            } else {
                let last = max(0, remaining - allocated)
                let roundedLast = (last * 10).rounded() / 10
                inputs.investmentItems[idx].allocationPercent = String(format: "%.1f", roundedLast)
            }
        }
    }
}
