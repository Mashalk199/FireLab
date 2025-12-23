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
    /// Yearly inflation rate (float whole number out of 100)
    @Published var inflationRateText: String = ""
    /// Yearly after-tax growth rate (float whole number out of 100)
    @Published var superGrowthRateText: String = ""
    /// Outstanding mortgage balance
    @Published var outstandingMortgageText: String = ""
    /// Mortgage yearly interest rate (float whole number out of 100)
    @Published var weeklyRentText: String = ""
    /// Mortgage minimum monthly payment
    @Published var mortgageYearlyInterestText: String = ""
    /// Weekly rent
    @Published var mortgageMinimumPaymentText: String = ""
    /// Sets the housing type of their housing details, whether it's a mortgage or rental
    @Published var housingType: HousingType = .mortgage
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
struct InvestmentItem: Identifiable, Codable, Equatable, Hashable {
    // Provide a property-level default so Decodable synthesis is happy
    let id: UUID = UUID()

    var name: String
    var type: InvestmentType
    var allocationPercent: String
    var expectedReturn: String
    var etfSnapshot: ETFDoc?  // runtime-only (not encoded)
    var autoCalc: Bool

    // Convenience init (no id parameter needed)
    init(
        name: String = "",
        type: InvestmentType = .etf,
        allocationPercent: String = "",
        expectedReturn: String = "",
        etfSnapshot: ETFDoc? = nil,
        autoCalc: Bool = false
    ) {
        self.name = name
        self.type = type
        self.allocationPercent = allocationPercent
        self.expectedReturn = expectedReturn
        self.etfSnapshot = etfSnapshot
        self.autoCalc = autoCalc
    }

    private enum CodingKeys: String, CodingKey {
        case name, type, allocationPercent, expectedReturn, autoCalc
    }
}


extension FireInputs {
    /// Seeds inputs to a sensible default configuration for previews / debug.
    static func mockDefaultConfig() -> FireInputs {
        let i = FireInputs()

        // User / timeline
        i.dateOfBirth = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()

        // Spending (annual, real)
        i.expensesText = "40000"

        // Contributions (enter yearly)
        i.FIContributionText = "14400"

        // Economy
        i.inflationRateText = "2.5"
        i.superGrowthRateText = "5.0"

        // Housing
        i.housingType = .rent
        i.weeklyRentText = "0"
        i.housingDetailsSet = .set

        // Real ETF snapshots (ADRA, FEMS, RTH)
        let adra = ETFDoc(
            symbol: "ADRA",
            name: "Invesco BLDRS Asia 50 ADR Index Fund",
            currency: "USD",
            exchange: "NASDAQ",
            micCode: "XNMS",
            country: "United States"
        )

        let fems = ETFDoc(
            symbol: "FEMS",
            name: "First Trust Emerging Markets Small Cap AlphaDEX Fund",
            currency: "USD",
            exchange: "NASDAQ",
            micCode: "XNMS",
            country: "United States"
        )

        let rth = ETFDoc(
            symbol: "RTH",
            name: "VanEck Retail ETF",
            currency: "USD",
            exchange: "NYSE",
            micCode: "ARCX",
            country: "United States"
        )

        // Future investments (ETFs + Bonds) - allocations sum to 100%. Hook snapshots into investment items.
        i.investmentItems = [
            InvestmentItem(
                name: "ADRA — Invesco BLDRS Asia 50 ADR",
                type: .etf,
                allocationPercent: "60",
                expectedReturn: "4.0",
                etfSnapshot: adra,
                autoCalc: false
            ),
            InvestmentItem(
                name: "FEMS — EM Small Cap AlphaDEX",
                type: .etf,
                allocationPercent: "30",
                expectedReturn: "4.5",
                etfSnapshot: fems,
                autoCalc: false
            ),
            InvestmentItem(
                name: "RTH — VanEck Retail",
                type: .etf,
                allocationPercent: "10",
                expectedReturn: "2",
                etfSnapshot: rth,
                autoCalc: false
            )
        ]

        // Current brokerage + super
        i.portfolioItems = [
            PortfolioItem(name: "Old ETF A", type: .etf,            value: "12000", expectedReturn: "4.5"),
            PortfolioItem(name: "Old ETF B", type: .etf,            value: "8000",  expectedReturn: "3.5"),
            PortfolioItem(name: "Old ETF C", type: .etf,            value: "5000",  expectedReturn: "5.5"),
            PortfolioItem(name: "My Super",  type: .superannuation, value: "25000", expectedReturn: i.superGrowthRateText)
        ]

        // Debts
        i.loanItems = [
            LoanItem(name: "Credit Card", outstandingBalance: "6000",  interestRate: "19.9", minimumPayment: "150"),
            LoanItem(name: "HECS-HELP",   outstandingBalance: "12000", interestRate: "4.7",  minimumPayment: "0"),
            LoanItem(name: "Car Loan",    outstandingBalance: "8500",  interestRate: "7.9",  minimumPayment: "300"),
        ]
        return i
    }
}
struct LoanItem: Identifiable {
    let id = UUID()
    var name: String
    var outstandingBalance: String
    var interestRate: String // (percentage, float whole number out of 100)
    var minimumPayment: String
}

struct PortfolioItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var type: InvestmentType
    var value: String
    var expectedReturn: String // (percentage, float whole number out of 100)
    
    private enum CodingKeys: String, CodingKey {
           case name, type, value, expectedReturn
       }
}
