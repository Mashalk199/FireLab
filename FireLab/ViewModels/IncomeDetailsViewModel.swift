//
//  IncomeDetailsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 27/1/2026.
//

import SwiftUI

@MainActor
final class IncomeDetailsViewModel: ObservableObject {

    @Published var salary: String = ""
    @Published var otherIncome: String = ""
    @Published var hasPrivateHealthCover: Bool = false

    @Published var errorText: String?
    @Published private var inputs: FireInputs?
    

    func attach(inputs: FireInputs) {
        guard self.inputs == nil else { return }
        self.inputs = inputs

        // PREFILL from FireInputs
        self.salary = inputs.employment.yearlyIncome
        self.otherIncome = inputs.employment.otherIncome
        self.hasPrivateHealthCover = inputs.employment.hasPrivateHealthCover
    }

    func validate() -> Bool {
        guard inputs != nil else { return false }

        guard let salaryVal = Double(salary), salaryVal >= 0 else {
            errorText = "Enter salary ≥ 0"
            return false
        }

        if !otherIncome.isEmpty {
            guard let otherVal = Double(otherIncome), otherVal >= 0 else {
                errorText = "Enter other income ≥ 0"
                return false
            }
        }

        errorText = nil
        return true
    }
}
