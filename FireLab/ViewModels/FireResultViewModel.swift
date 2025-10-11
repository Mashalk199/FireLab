//
//  FireResultViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 5/10/2025.
//

import Foundation
import SwiftUI

@MainActor
final class FireResultViewModel: ObservableObject {
    // View state
    @Published var isCalculating = false
    @Published var result: Result?
    @Published var errorText: String?

    // Keep a strong hold to reuse the same result screen without recalculating
    private var lastInputsSnapshot: FireInputs?
    private let calculator: FireCalculatorService
    init(calculator: FireCalculatorService = FireCalculatorService()) {
        self.calculator = calculator
    }

    func run(inputs: FireInputs) {
        // Don’t rerun if we already calculated for the same object instance and have a result
        if let snap = lastInputsSnapshot, snap === inputs, result != nil { return }

        isCalculating = true
        errorText = nil
        lastInputsSnapshot = inputs

        Task {
            let start = Date()
            do {
                // run the heavy work off the main thread
                let r = try await calculator.calculateRetirement(inputs: inputs)

                // publish
                self.result = r
            } catch {
                self.errorText = error.localizedDescription
            }
            self.isCalculating = false

            let elapsed = Date().timeIntervalSince(start)
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            print("Calculation took \(minutes)m \(seconds)s")
        }
    }
}
