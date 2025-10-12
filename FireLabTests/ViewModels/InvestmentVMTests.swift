//
//  InvestmentVMTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

/// Tests validation logic inside InvestmentViewModel. Ensures correct handling of total allocation percentages and error messaging.
@MainActor
final class InvestmentVMTests: XCTestCase {
    // Tests a valid case where allocation sums exactly to 100%.
    // Expect: totalPercent = 100 and validation succeeds with no error message.
    func testTotalPercentAndValidation() {
        let inputs = FireInputs()
        inputs.investmentItems = [
            .init(name: "A", type: .etf, allocationPercent: "50", expectedReturn: "4", etfSnapshot: nil, autoCalc: false),
            .init(name: "B", type: .etf, allocationPercent: "50", expectedReturn: "4", etfSnapshot: nil, autoCalc: false)
        ]
        let vm = InvestmentViewModel()
        vm.attach(inputs: inputs)
        XCTAssertEqual(vm.totalPercent, 100, accuracy: 1e-9)
        XCTAssertTrue(vm.validate())
    }

    // Tests an invalid configuration where total allocation > 100%.
    // Expect: validate() returns false and errorText is populated.
    func testValidateFailWhenOver100() {
        let inputs = FireInputs()
        inputs.investmentItems = [
            .init(name: "A", type: .etf, allocationPercent: "80", expectedReturn: "4", etfSnapshot: nil, autoCalc: false),
            .init(name: "B", type: .etf, allocationPercent: "30", expectedReturn: "4", etfSnapshot: nil, autoCalc: false)
        ]
        let vm = InvestmentViewModel()
        vm.attach(inputs: inputs)
        XCTAssertFalse(vm.validate())
        XCTAssertNotNil(vm.errorText)
    }
}
