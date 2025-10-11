//
//  FinancialData.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 10/10/2025.
//

import Foundation

/// This is the root json object of the financial REST API's response
struct FinancialData: Decodable {
    let values: [ETFPrice]
}
/// This is the model of the data we query from the financial REST API, which include the ETF prices and dates.
struct ETFPrice: Decodable {
    let datetime: Date
    let close: Double

    private enum CodingKeys: String, CodingKey {
        case datetime, close
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Date decoding accepts plain date strings like "2025-10-08"
        let dateStr = try container.decode(String.self, forKey: .datetime)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Australia/Sydney")
        datetime = formatter.date(from: dateStr) ?? Date.distantPast

        // decode string number to double
        let closeString = try container.decode(String.self, forKey: .close)
        close = Double(closeString) ?? 0.0
    }
}
