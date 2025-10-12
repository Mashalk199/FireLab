//
//  ChartRangeControllerTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

/// Unit tests for ChartRangeController.clamped().

// Verifies that the displayed chart range always respects the minimum span and stays within global date limits even when the requested range is too small.
final class ChartRangeControllerTests: XCTestCase {
    /// Tests that the clamped range respects both lower/upper limits and the minimum visible time span
    func testClampRespectsMinSpanAndBounds() {
        let c = ChartRangeController(minSpan: 14*24*3600)
        let base = Date(timeIntervalSince1970: 0)
        let full = base ... base.addingTimeInterval(60*24*3600)
        let tooSmall = base.addingTimeInterval(1*24*3600) ... base.addingTimeInterval(2*24*3600)
        let got = c.clamped(tooSmall, to: full)
        let span = got.upperBound.timeIntervalSince(got.lowerBound)
        
        // span should be at least 14 days and within the allowed limits.
        XCTAssertGreaterThanOrEqual(span, 14*24*3600 - 5, "Min span not clamped properly")
        XCTAssertTrue(full.contains(got.lowerBound) && full.contains(got.upperBound))
    }
}
