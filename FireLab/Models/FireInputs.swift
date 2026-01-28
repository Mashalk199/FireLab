//
//  FireInputs.swift
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
    /// Employment details (salary + employer super)
    @Published var employment: Employment = Employment()
    /// Superannuation object containing all superannuation details
    @Published var superannuation: Superannuation = Superannuation()
    /// Outstanding mortgage balance
    @Published var outstandingMortgageText: String = ""
    /// Mortgage yearly interest rate (float whole number out of 100)
    @Published var mortgageYearlyInterestText: String = ""
    /// Weekly rent
    @Published var weeklyRentText: String = ""
    /// Mortgage minimum monthly payment
    @Published var mortgageMinimumPaymentText: String = ""
    /// List of all investments the user has added. This is the investments they will plan on investing into in the future, containing allocations
    @Published var investmentItems: [InvestmentItem] = []
    /// List of all portfolio items the user has added. This is the investments they already invested in in the past
    @Published var portfolioItems: [PortfolioItem] = []
    /// List of all loan items the user has added.
    @Published var loanItems: [LoanItem] = []
}



/** Investment type enum */
enum InvestmentType: String, Codable { case etf, bond, superannuation }

/** This object stores the details of a particular investment, whether it is an existing ETF selected from the database, or a user-created bond */
struct InvestmentItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID = UUID()
    var name: String
    var type: InvestmentType
    var allocationPercent: String
    var expectedReturn: String
    var currentValue: String
    var etfSnapshot: ETFDoc?
    var autoCalc: Bool

    init(
        name: String = "",
        type: InvestmentType = .etf,
        allocationPercent: String = "",
        expectedReturn: String = "",
        currentValue: String = "",
        etfSnapshot: ETFDoc? = nil,
        autoCalc: Bool = false
    ) {
        self.name = name
        self.type = type
        self.allocationPercent = allocationPercent
        self.expectedReturn = expectedReturn
        self.currentValue = currentValue
        self.etfSnapshot = etfSnapshot
        self.autoCalc = autoCalc
    }

    private enum CodingKeys: String, CodingKey {
        case name, type, allocationPercent, expectedReturn, currentValue, autoCalc
    }
}

/** Employment struct for salary and employer super details */
struct Employment {
    /// Gross annual salary before tax
    var yearlyIncome: String = ""
    
    /// Employer super contribution percentage (e.g., 11.5)
    var employerSuperRate: String = ""
    
    /// Optional: other taxable income
    var otherIncome: String = ""
    
    /// Optional: private hospital cover for MLS
    var hasPrivateHealthCover: Bool = false
}

struct Superannuation {
    /// Current super balance
    var value: String = ""
    
    /// Expected annual return (percentage)
    var expectedReturn: String = ""
    
    /// Voluntary concessional contributions (monthly)
    var concessional: String = ""
    
    /// Voluntary non-concessional contributions (monthly)
    var nonConcessional: String = ""
    
    /// Retirement spending as a percentage of current expenses
    var retirementMultiplier: String = ""
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

        // Employment
        i.employment.yearlyIncome = "80000"
        i.employment.employerSuperRate = "11.5"
        i.employment.otherIncome = "5000"
        i.employment.hasPrivateHealthCover = true

        // Superannuation
        i.superannuation.value = "25000"
        i.superannuation.expectedReturn = "6.0"
        i.superannuation.concessional = "500"
        i.superannuation.nonConcessional = "200"
        i.superannuation.retirementMultiplier = "80"

        // Housing
        i.weeklyRentText = "0"

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

        // Future investments (ETFs + Bonds)
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
            PortfolioItem(name: "Old ETF A", type: .etf, value: "12000", expectedReturn: "4.5"),
            PortfolioItem(name: "Old ETF B", type: .etf, value: "8000", expectedReturn: "3.5"),
            PortfolioItem(name: "Old ETF C", type: .etf, value: "5000", expectedReturn: "5.5")
        ]

        // Debts
        i.loanItems = [
            LoanItem(name: "Credit Card", outstandingBalance: "6000", interestRate: "19.9", minimumPayment: "150"),
            LoanItem(name: "HECS-HELP", outstandingBalance: "12000", interestRate: "4.7", minimumPayment: "0"),
            LoanItem(name: "Car Loan", outstandingBalance: "8500", interestRate: "7.9", minimumPayment: "300")
        ]

        return i
    }
}

/** LoanItem struct */
struct LoanItem: Identifiable {
    let id = UUID()
    var name: String
    var outstandingBalance: String
    var interestRate: String
    var minimumPayment: String
    
    init(
        name: String = "",
        outstandingBalance: String = "",
        interestRate: String = "",
        minimumPayment: String = ""
    ) {
        self.name = name
        self.outstandingBalance = outstandingBalance
        self.interestRate = interestRate
        self.minimumPayment = minimumPayment
    }
}

/** PortfolioItem struct */
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
