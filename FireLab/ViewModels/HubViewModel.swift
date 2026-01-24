//
//  AddDetailsHubViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class HubViewModel: ObservableObject {
    @Published var errorText: String?
    private var inputs: FireInputs?

    func attach(inputs: FireInputs) { self.inputs = inputs }

    func validate() -> Bool {
        guard let inputs else { return false }
        let cal = Calendar.current

        guard let y14 = cal.date(byAdding: .month, value: -14 * 12 - 9, to: Date()),
              inputs.dateOfBirth < y14 else {
            errorText = "You must be at least 14 years and 9 months old to be able to work!"
            return false
        }
        guard let exp = Double(inputs.expensesText), exp > 0 else { errorText = "Enter yearly expenses > 0"; return false }
        guard let cont = Double(inputs.FIContributionText), cont > 0 else { errorText = "Enter contribution > 0"; return false }
        guard let infl = Double(inputs.inflationRateText), (0...100).contains(infl) else { errorText = "Enter 100 >= inflation rate >= 0"; return false }
        guard !inputs.superannuation.value.isEmpty else { errorText = "Please enter superannuation details."; return false }

        errorText = nil
        return true
    }
}
