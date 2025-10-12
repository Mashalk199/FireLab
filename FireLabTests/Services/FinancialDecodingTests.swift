//
//  FinancialDecodingTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

/// Tests decoding of a sample JSON fixture into the FinancialData model.

// Ensures the decoding logic correctly parses array length and numeric values
final class FinancialDecodingTests: XCTestCase {
    func testDecodeTimeSeriesFromFixture() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "time_series_sample", withExtension: "json") else {
            XCTFail("Missing fixture time_series_sample.json in FireLabTests bundle")
            return
        }
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(FinancialData.self, from: data)
        XCTAssertEqual(decoded.values.count, 3)
        XCTAssertEqual(decoded.values.first?.close ?? -1, 100.5, accuracy: 1e-9)
    }
}
