//
//  MockFinancialDataService.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import Foundation

/// A mock implementation of the FinancialDataFetching protocol. Provides deterministic fake data for unit and integration tests without calling the live financial data API.
final class MockFinancialDataService: FinancialDataFetching {
    var seriesBySymbol: [String:[Double]] = [:]
    var shouldThrow = false
    enum E: Error { case boom }
    
    func fetchTimeSeries(symbol: String, endDate: Date) async throws -> [Double] {
        if shouldThrow { throw E.boom }
        return seriesBySymbol[symbol] ?? []
    }
}
