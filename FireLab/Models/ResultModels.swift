//
//  ResultModels.swift
//  FireLab
//
//  Created by YIHAN  on 7/10/2025.
//

/// Defines lightweight data models used in result calculations and persistence. Specifically includes DebtRemnant, a simple struct that replaces tuples for encoding remaining debt information in Codable format.

import Foundation

//Represents a single remaining debt (name + balance) after calculations. This replaces tuple-based debt storage, making the model Codable and SwiftData-compatible.

struct DebtRemnant: Codable, Hashable {
    let name: String
    let balance: Double
}
