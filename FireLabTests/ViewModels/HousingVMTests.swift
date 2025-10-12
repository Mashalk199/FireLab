//
//  HousingVMTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

/// Tests the housing-specific validation logic in HousingDetailsViewModel. Confirms that rent and mortgage branches behave according to user input.
@MainActor
final class HousingVMTests: XCTestCase {
    // Tests the "rent" path with valid weekly rent input.
    // Expect: validate() returns true and no error message is set.
    func testRentPathValid() {
        let inputs = FireInputs()
        inputs.housingType = .rent
        inputs.weeklyRentText = "400"
        let vm = HousingDetailsViewModel()
        vm.attach(inputs: inputs)
        XCTAssertTrue(vm.validate())
    }

    // Tests the "mortgage" path with missing values.
    // Expect: validation fails and errorText provides feedback.
    func testMortgagePathInvalidWhenMissingValues() {
        let inputs = FireInputs()
        inputs.housingType = .mortgage
        inputs.outstandingMortgageText = "0"
        inputs.mortgageYearlyInterestText = "5"
        inputs.mortgageMinimumPaymentText = "0"
        let vm = HousingDetailsViewModel()
        vm.attach(inputs: inputs)
        XCTAssertFalse(vm.validate())
        XCTAssertNotNil(vm.errorText)
    }
}
