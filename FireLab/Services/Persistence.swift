//
//  Persistence.swift
//  FireLab
//
//  Created by YIHAN  on 7/10/2025.
//

/// Handles data persistence for FireLab using SwiftData.
/// Encodes FireInputs and Result into JSON, saves the latest 3 runs, and provides helper functions to fetch or decode records.

import Foundation
import SwiftData

@Model
final class CalcRecord {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var inputsJSON: Data // Encoded FireInputsSnapshot
    var resultJSON: Data // Encoded Result
    
    init(id: UUID = UUID(), createdAt: Date = .now, inputsJSON: Data, resultJSON: Data) {
        self.id = id
        self.createdAt = createdAt
        self.inputsJSON = inputsJSON
        self.resultJSON = resultJSON
    }
}


// Simplified version of LoanItem to make it Codable
struct LoanItemDTO: Codable {
    var name: String
    var outstandingBalance: String
    var interestRate: String
    var minimumPayment: String
}

// Snapshot of user inputs, fully Codable for persistence.
struct FireInputsSnapshot: Codable {
    var dateOfBirth: Date
    var expensesText: String
    var FIContributionText: String
    var inflationRateText: String
    var outstandingMortgageText: String
    var weeklyRentText: String
    var mortgageYearlyInterestText: String
    var mortgageMinimumPaymentText: String
    
    var housingTypeRaw: String
    var housingDetailsSetRaw: String
    
    var investmentItems: [InvestmentItem]
    var portfolioItems: [PortfolioItem]
    var loanItems: [LoanItemDTO]
}

extension FireInputs {
    // Converts the current live inputs into a Codable snapshot for savin
    func toSnapshot() -> FireInputsSnapshot {
        let loanDTOs = self.loanItems.map { li in
            LoanItemDTO(
                name: li.name,
                outstandingBalance: li.outstandingBalance,
                interestRate: li.interestRate,
                minimumPayment: li.minimumPayment
            )
        }
        return FireInputsSnapshot(
            dateOfBirth: self.dateOfBirth,
            expensesText: self.expensesText,
            FIContributionText: self.FIContributionText,
            inflationRateText: self.inflationRateText,
            outstandingMortgageText: self.outstandingMortgageText,
            weeklyRentText: self.weeklyRentText,
            mortgageYearlyInterestText: self.mortgageYearlyInterestText,
            mortgageMinimumPaymentText: self.mortgageMinimumPaymentText,
            housingTypeRaw: (self.housingType == .mortgage ? "mortgage" : "rent"),
            housingDetailsSetRaw: (self.housingDetailsSet == .set ? "set" : "unset"),
            investmentItems: self.investmentItems,
            portfolioItems: self.portfolioItems,
            loanItems: loanDTOs
        )
    }
    
    // Re-applies a saved snapshot back into the current FireInputs object.
    func apply(snapshot s: FireInputsSnapshot) {
        self.dateOfBirth = s.dateOfBirth
        self.expensesText = s.expensesText
        self.FIContributionText = s.FIContributionText
        self.inflationRateText = s.inflationRateText
        self.outstandingMortgageText = s.outstandingMortgageText
        self.weeklyRentText = s.weeklyRentText
        self.mortgageYearlyInterestText = s.mortgageYearlyInterestText
        self.mortgageMinimumPaymentText = s.mortgageMinimumPaymentText
        self.housingType = (s.housingTypeRaw == "mortgage" ? .mortgage : .rent)
        self.housingDetailsSet = (s.housingDetailsSetRaw == "set" ? .set : .unset)
        self.investmentItems = s.investmentItems
        self.portfolioItems = s.portfolioItems
        self.loanItems = s.loanItems.map {
            LoanItem(name: $0.name,
                     outstandingBalance: $0.outstandingBalance,
                     interestRate: $0.interestRate,
                     minimumPayment: $0.minimumPayment)
        }
    }
}

// A static helper for encoding, decoding and maintaining only the latest 3 saved records.
enum Persistence {
    private static let enc: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    private static let dec: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    // Saves the latest run (inputs + results) and trims to last 3.
    static func saveLatest3(context: ModelContext, inputs: FireInputs, result: Result) {
        do {
            let inputsData = try enc.encode(inputs.toSnapshot())
            let resultData = try enc.encode(result)
            context.insert(CalcRecord(inputsJSON: inputsData, resultJSON: resultData))
            
            let fd = FetchDescriptor<CalcRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let all = try context.fetch(fd)
            for old in all.dropFirst(3) { context.delete(old) }
            
            try context.save()
        } catch {
            print("Persistence.saveLatest3 error:", error)
        }
    }
    
    // Fetch the top 3 most recent calculation records.
    static func fetchTop3(context: ModelContext) -> [CalcRecord] {
        var fd = FetchDescriptor<CalcRecord>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        fd.fetchLimit = 3
        return (try? context.fetch(fd)) ?? []
    }
    
    // Decode a saved record back into readable inputs and results.
    static func decode(record: CalcRecord) -> (FireInputsSnapshot, Result)? {
        guard let snap = try? dec.decode(FireInputsSnapshot.self, from: record.inputsJSON),
              let res  = try? dec.decode(Result.self, from: record.resultJSON) else { return nil }
        return (snap, res)
    }
    
    struct SnapshotFile: Codable {
        let generatedAt: Date
        let inputs: FireInputsSnapshot
        let result: Result
    }

    static func encodeSnapshot(record: CalcRecord) -> Data? {
            guard let (inputs, result) = decode(record: record) else { return nil }
            let file = SnapshotFile(generatedAt: .now, inputs: inputs, result: result)
            let e = JSONEncoder()
            e.outputFormatting = [.prettyPrinted, .sortedKeys]
            e.dateEncodingStrategy = .iso8601
            return try? e.encode(file)
        }

        static func decodeSnapshot(_ data: Data) -> (FireInputsSnapshot, Result)? {
            let d = JSONDecoder()
            d.dateDecodingStrategy = .iso8601
            guard let file = try? d.decode(SnapshotFile.self, from: data) else { return nil }
            return (file.inputs, file.result)
        }
}
