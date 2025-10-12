//
//  PersistenceTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest
import SwiftData

/// Tests that only the latest three calculation records are kept in persistence. Ensures that older results are pruned after additional saves.
final class PersistenceTests: XCTestCase {
    func testSaveLatestThreeOnly() throws {
        let ctx = try InMemory.context()
        let inputs = FireInputs.mockDefaultConfig()
        for i in 0..<4 {
            let res = Result(
                workingDays: i, retirementDate: .now,
                brokerProp: 0.5, monthlyBrokerContribution: 0, monthlySuperContribution: 0,
                brokerageBalanceAtRetirement: 0, superBalanceAtRetirement: 0,
                debtClearDays: 0, remainingDebts: [], brokerageSeries: []
            )
            Persistence.saveLatest3(context: ctx, inputs: inputs, result: res)
        }
        let got = try ctx.fetch(FetchDescriptor<CalcRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
        XCTAssertEqual(got.count, 3)
    }
}
