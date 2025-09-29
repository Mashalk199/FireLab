//
//  Data.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 21/8/2025.
//

import Foundation
/**
 This object stores all user inputs collected across all app screens to be used in the final calculation in an environment object.
 
 This data includes:
    - Date of birth
    - Yearly expenses
    - Yearly financial independence contribution amount
    - Assumed yearly inflation rate
    - Assumed yearly superannuation after-tax growth rate
    - A list of InvestmentItem objects that store details about each investment in the user's investment plan including names and growth rates.
 */
class FireInputs: ObservableObject {
    @Published var dateOfBirth: Date = Date()
    @Published var expensesText: String = ""
    @Published var FIContributionText: String = ""
    @Published var inflationRateText: String = ""
    @Published var superGrowthRateText: String = ""
    @Published var outstandingMortgageText: String = ""
    @Published var mortgageYearlyInterestText: String = ""
    @Published var weeklyRentText: String = ""
    @Published var mortgageMinimumPaymentText: String = ""
    @Published var housingDetailsSet: HousingDetailsSet = .unset
    @Published var investmentItems: [InvestmentItem] = []
    @Published var portfolioItems: [PortfolioItem] = []
    @Published var loanItems: [LoanItem] = []

}
enum InvestmentType: String, Codable { case etf, bond, superannuation }
/// This object stores the details of a particular investment, whether it is an existing ETF selected from the database, or a user-created bond
struct InvestmentItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var type: InvestmentType
    var allocationPercent: String
    var expectedReturn: String
    
    private enum CodingKeys: String, CodingKey {
           case name, type, allocationPercent, expectedReturn
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
