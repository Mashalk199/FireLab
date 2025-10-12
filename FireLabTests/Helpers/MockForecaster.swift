//
//  MockForecaster.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import Foundation

/// A mock implementation of the Forecasting protocol. Used to replace the MLForecastService in tests, so predictions are predictable and fast.
final class MockForecaster: Forecasting {
    var returns: [Double] = []
    var shouldThrow = false
    struct Err: Error {}

    func predictReturns(closes: [Double], steps: Int) throws -> [Double] {
        if shouldThrow { throw Err() }
        if returns.isEmpty { return Array(repeating: 0.0, count: steps) }
        if returns.count >= steps { return Array(returns.prefix(steps)) }
        var out = returns
        out.append(contentsOf: Array(repeating: returns.last ?? 0.0, count: steps - returns.count))
        return out
    }
}
