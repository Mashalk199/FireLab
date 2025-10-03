//
//  LoanDetailsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class LoanDetailsViewModel: ObservableObject {
    // ViewModel holds a reference to the shared inputs so mutations affect the app model
    private var inputs: FireInputs?

    // attach the EnvironmentObject after the View is created
    func attach(inputs: FireInputs) { self.inputs = inputs }

    // deletion centralised in the VM (called from the cell)
    func delete(loanID: UUID) {
        guard let inputs else { return }
        if let idx = inputs.loanItems.firstIndex(where: { $0.id == loanID }) {
            inputs.loanItems.remove(at: idx)
        }
    }
}
