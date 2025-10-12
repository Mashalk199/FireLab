//
//  FireCalculatorUtilsTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

/// Tests the conversion of annual return and inflation into daily compounded return factors.

// Verifies mathematical correctness of the helper `_test_dailyReturn()`.
final class FireCalculatorUtilsTests: XCTestCase {
    func testGetDailyReturn_positivesAndInflation() {
        let r = 0.05, i = 0.02
        let expected = pow((1+r)/(1+i), 1.0/365.0)
        let actual = FireCalculatorService()._test_dailyReturn(annualReturn: r, inflation: i)
        XCTAssertEqual(actual, expected, accuracy: 1e-12)
    }
}
