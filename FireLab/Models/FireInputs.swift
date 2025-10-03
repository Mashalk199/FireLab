//
//  Data.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 21/8/2025.
//

import Foundation
/**
 This object stores all user inputs collected across all app screens to be used in the final calculation in an environment object.
 */
class FireInputs: ObservableObject {
    /// Date of birth of user
    @Published var dateOfBirth: Date = Date()
    /// Yearly non-housing expenses
    @Published var expensesText: String = ""
    /// Yearly financial independence contribution
    @Published var FIContributionText: String = ""
    /// Yearly inflation rate
    @Published var inflationRateText: String = ""
    /// Yearly after-tax growth rate
    @Published var superGrowthRateText: String = ""
    /// Outstanding mortgage balance
    @Published var outstandingMortgageText: String = ""
    /// Mortgage yearly interest rate
    @Published var weeklyRentText: String = ""
    /// Mortgage minimum monthly payment
    @Published var mortgageYearlyInterestText: String = ""
    /// Weekly rent
    @Published var mortgageMinimumPaymentText: String = ""
    /// Checks whether the housing details were set by the user or not
    @Published var housingDetailsSet: HousingDetailsSet = .unset
    /// List of all investments the user has added. This is the investments they will plan on investing into in the future, containing allocations
    @Published var investmentItems: [InvestmentItem] = []
    /// List of all portfolio items the user has added. This is the investments they already invested in in the past
    @Published var portfolioItems: [PortfolioItem] = []
    /// List of all loan items the user has added.
    @Published var loanItems: [LoanItem] = []

}
enum InvestmentType: String, Codable { case etf, bond, superannuation }
/// This object stores the details of a particular investment, whether it is an existing ETF selected from the database, or a user-created bond
struct InvestmentItem: Identifiable, Hashable, Codable {
    let id = UUID()

    // Fields your calculator already uses
    var name: String
    var type: InvestmentType
    var allocationPercent: String
    var expectedReturn: String

    var etfSnapshot: ETFDoc?  // nil for bonds

    // Convenience
    var isETF: Bool { type == .etf }

    private enum CodingKeys: String, CodingKey {
        case name, type, allocationPercent, expectedReturn, etfSnapshot
    }
}
struct LoanItem: Identifiable {
    let id = UUID()
    var name: String
    var outstandingBalance: String
    var interestRate: String
    var minimumPayment: String
}

struct PortfolioItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var type: InvestmentType
    var value: String
    var expectedReturn: String
    
    private enum CodingKeys: String, CodingKey {
           case name, type, value, expectedReturn
       }
}
