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
    @Published private var inputs: FireInputs?
    func attach(inputs: FireInputs) { if self.inputs == nil { self.inputs = inputs } }
    
    /// This computed property computes the total percentage allocated by the user across all investments displayed.
    var totalPercent: Double {
        guard let inputs else { return 0 }
        return inputs.investmentItems
            .map { Double($0.allocationPercent.trimmingCharacters(in: .whitespaces)) ?? 0 }
            .reduce(0, +)
    }

    /// True only when: there is at least one investment, all have valid allocations (0 < x ≤ 100), and totals ~ 100%.
    var canCalculate: Bool {
        guard let inputs, !inputs.investmentItems.isEmpty else { return false }
        // Every allocation must parse and be in (0, 100]
        let allItemsValid = inputs.investmentItems.allSatisfy { item in
            guard let v = Double(item.allocationPercent.trimmingCharacters(in: .whitespaces)) else { return false }
            return v > 0 && v <= 100
        }
        guard allItemsValid else { return false }
        return abs(totalPercent - 100) < 0.01
    }
    
    func removeItem(_ item: InvestmentItem) {
        guard let inputs else { return }

        if let idx = inputs.investmentItems.firstIndex(where: { $0.id == item.id }) {
            inputs.investmentItems.remove(at: idx)
        }
    }
    
    // Function to validate all user inputs moved from View
    func validate() -> Bool {
        guard let inputs else { return false }
        
        // Per-item checks (also provide specific error messages)
        for item in inputs.investmentItems {
            let raw = item.allocationPercent.trimmingCharacters(in: .whitespaces)
            guard let v = Double(raw) else {
                errorText = "Please enter valid percentage allocations for \(item.name)"
                return false
            }
            if v <= 0 {
                errorText = "Allocation for \(item.name) must be greater than 0%"
                return false
            }
            if v > 100 {
                errorText = "Allocation for \(item.name) must be at most 100%"
                return false
            }
        }
        
        // Ensure there is at least one investment
        guard !inputs.investmentItems.isEmpty else {
            errorText = "Please add at least one investment"
            return false
        }
        
        // Total must sum to ~100%
        guard abs(totalPercent - 100) < 0.01 else {
            errorText = "Please ensure total allocation percentages sum to 100%"
            return false
        }
        
        errorText = nil
        return true
    }
    
    /// Autocompletes all unfilled allocations with an equal allocation.
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
