//
//  InMemoryContainer.swift
//  FireLabTests
//
//  Created by YIHAN  on 12/10/2025.
//

@testable import FireLab
import SwiftData

/// providing an in-memory SwiftData container and context. Allows testing of persistence logic without writing to disk.
enum InMemory {
    static func container() throws -> ModelContainer {
        let schema = Schema([CalcRecord.self])
        return try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
    static func context() throws -> ModelContext {
        ModelContext(try container())
    }
}
