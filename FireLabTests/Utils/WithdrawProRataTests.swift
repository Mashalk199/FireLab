//
//  WithdrawProRataTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

func XCTAssertEqual(_ a: [Double], _ b: [Double], accuracy: Double, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(a.count, b.count, "Array counts differ", file: file, line: line)
    for (x, y) in zip(a, b) {
        XCTAssertEqual(x, y, accuracy: accuracy, file: file, line: line)
    }
}

/// Unit tests for FireCalculatorService.withdrawProRata() logic.

// Ensures withdrawal amounts are correctly distributed between multiple assets.
final class WithdrawProRataTests: XCTestCase {
    // Tests that withdrawal is distributed according to custom weights when provided.
    // Expect: assets reduced proportionally to the weights, and no leftover amount.
    func testWithdrawWithWeights() {
        var vec = [100.0, 300.0, 600.0]
        let weights = [0.2, 0.3, 0.5]
        let leftover = FireCalculatorService()._test_withdraw(&vec, weights: weights, amount: 300)
        XCTAssertEqual(leftover, 0, accuracy: 1e-9)
        zip(vec, [40.0, 210.0, 450.0]).forEach {
            XCTAssertEqual($0, $1, accuracy: 1e-6)
        }
    }

    // Tests that if weights are nil, withdrawal is value-weighted by asset size.
    // Expect: assets reduced based on their value share, total reduction equals amount.
    func testWithdrawValueWeightedWhenWeightsNil() {
        var vec = [100.0, 300.0, 600.0]
        let leftover = FireCalculatorService()._test_withdraw(&vec, weights: nil, amount: 100)
        XCTAssertEqual(vec.map{round($0)}, [90, 270, 540]) 
        XCTAssertEqual(leftover, 0, accuracy: 1e-9)
    }

    // Tests that when total balance < withdrawal amount, leftover is returned correctly.
    // Expect: all balances reduced to zero and leftover equals remaining shortfall.
    func testWithdrawInsufficientFundsReturnsLeftover() {
        var vec = [10.0, 0.0]
        let leftover = FireCalculatorService()._test_withdraw(&vec, weights: nil, amount: 50)
        XCTAssertEqual(leftover, 40, accuracy: 1e-9)
        XCTAssertEqual(vec, [0, 0], accuracy: 1e-9)
    }
}
