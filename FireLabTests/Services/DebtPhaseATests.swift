//
//  DebtPhaseATests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

/// test for the “Phase A” debt avalanche logic in FireCalculatorService.

// Ensures that higher-interest debts are prioritised for repayment before lower-interest debts.
final class DebtPhaseATests: XCTestCase {
    // Tests that after the debt avalanche process runs, the balance of high-APR debt should be smaller than or equal to the low-APR debt.
    func testHighAPRIsAvalanchedBeforeLowAPR() async throws {
        let mockData = MockFinancialDataService()
        let fore = MockForecaster(); fore.returns = Array(repeating: 0.0, count: 365*2)
        let svc = FireCalculatorService(
            dataService: mockData, fullForecaster: fore, shortForecaster: fore
        )
        let inputs = FireInputs()
        inputs.dateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: .now)!
        inputs.expensesText = "10000"
        inputs.FIContributionText = "12000"
        inputs.inflationRateText = "2"
        inputs.superGrowthRateText = "5"
        inputs.housingType = .rent
        inputs.weeklyRentText = "0"
        inputs.housingDetailsSet = .set

        inputs.investmentItems = [
            .init(name: "X", type: .etf, allocationPercent: "100", expectedReturn: "50", etfSnapshot: nil, autoCalc: false)
        ]

        inputs.loanItems = [
            .init(name: "High", outstandingBalance: "1000", interestRate: "60", minimumPayment: "0"),
            .init(name: "Low",  outstandingBalance: "1000", interestRate: "1",  minimumPayment: "0")
        ]

        let res = try await svc.calculateRetirement(inputs: inputs)
        XCTAssertFalse(res.remainingDebts.isEmpty)
        let map = Dictionary(uniqueKeysWithValues: res.remainingDebts.map{ ($0.name, $0.balance) })
        let high = map["High"] ?? 0
        let low = map["Low"] ?? .infinity
        XCTAssertLessThanOrEqual(high, low + 1, "High APR debt should be <= Low APR after avalanche phase")
    }
}
