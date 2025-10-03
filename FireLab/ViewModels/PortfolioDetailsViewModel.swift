//
//  PortfolioDetailsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//


//
//  PortfolioDetailsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class PortfolioDetailsViewModel: ObservableObject {
    // Keep a reference to app state to perform mutations like delete.
    // Stored as weak to avoid accidental retain cycles.
    private weak var inputs: FireInputs?

    func attach(inputs: FireInputs) { self.inputs = inputs }

    // Formats a numeric string into AUD, otherwise returns the original.
    func formattedValue(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let v = Double(trimmed) {
            return v.formatted(.currency(code: "AUD"))
        } else {
            return raw
        }
    }

    // Remove a portfolio item by id from the shared app state.
    func delete(itemID: UUID) {
        guard var list = inputs?.portfolioItems else { return }
        if let idx = list.firstIndex(where: { $0.id == itemID }) {
            list.remove(at: idx)
            inputs?.portfolioItems = list
        }
    }
}