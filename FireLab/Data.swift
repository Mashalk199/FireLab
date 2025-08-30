//
//  Data.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 21/8/2025.
//

import Foundation
class FireInputs: ObservableObject {
    @Published var yearlyIncomeText: String = ""
    @Published var nonHousingText: String = ""
    @Published var FIContributionText: String = ""
    @Published var items: [InvestmentItem] = []

}
enum InvestmentType: String, Codable { case etf, bond }

struct InvestmentItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var type: InvestmentType
    var allocationPercent: String = ""
    var amount: String = ""
    var expectedReturn: String = ""
    
    private enum CodingKeys: String, CodingKey {
           case name, type, allocationPercent, amount, expectedReturn
       }
}
