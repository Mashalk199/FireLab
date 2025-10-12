//
//  PersistenceDecodeTests.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import XCTest
import SwiftData

/// Tests end-to-end persistence encoding/decoding using an in-memory SwiftData context. Verifies that a saved calculation record can be fetched and correctly decoded back.
final class PersistenceDecodeTests: XCTestCase {
    func testEncodeThenDecodeRoundTrip() throws {
        let ctx = try InMemory.context()
        let inputs = FireInputs.mockDefaultConfig()
        let res = Result(
            workingDays: 123, retirementDate: Date(timeIntervalSince1970: 0),
            brokerProp: 0.42, monthlyBrokerContribution: 100, monthlySuperContribution: 200,
            brokerageBalanceAtRetirement: 1111, superBalanceAtRetirement: 2222,
            debtClearDays: 0, remainingDebts: [], brokerageSeries: [1,2,3]
        )
        Persistence.saveLatest3(context: ctx, inputs: inputs, result: res)
        let list = try ctx.fetch(FetchDescriptor<CalcRecord>())
        XCTAssertEqual(list.count, 1)
        let decoded = Persistence.decode(record: list[0])!
        XCTAssertEqual(decoded.1.workingDays, 123)
        XCTAssertEqual(decoded.1.brokerageSeries, [1,2,3])
    }
}
