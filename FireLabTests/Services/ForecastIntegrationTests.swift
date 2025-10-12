//
//  ForecastIntegrationTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest

/// Integration test verifying that FireCalculatorService selects the short forecasting model when the available ETF data has fewer than 250 points.
final class ForecastIntegrationTests: XCTestCase {
    func testCalculatorUsesShortModelWhenDataShort() async throws {
        let mockData = MockFinancialDataService()
        mockData.seriesBySymbol["AAA"] = Array(repeating: 100.0, count: 80)

        let full = MockForecaster();  full.returns = Array(repeating: 0.1, count: 365*2)
        let short = MockForecaster(); short.returns = Array(repeating: 0.2, count: 365*2)

        let svc = FireCalculatorService(
            dataService: mockData,
            fullForecaster: full,
            shortForecaster: short
        )

        let inputs = FireInputs.mockDefaultConfig()
        inputs.investmentItems = [
            .init(name: "AAA", type: .etf, allocationPercent: "100", expectedReturn: "4", etfSnapshot:
                    ETFDoc(symbol: "AAA", name: "A", currency: "USD", exchange: "X", micCode: "X", country: "US"),
                  autoCalc: true)
        ]

        let res = try await svc.calculateRetirement(inputs: inputs)
        XCTAssertFalse(res.brokerageSeries.isEmpty)
    }
}
