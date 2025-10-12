//
//  HousingDetailsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 3/10/2025.
//

import Foundation

@MainActor
final class HousingDetailsViewModel: ObservableObject {
    @Published var errorText: String?

    private var inputs: FireInputs?

    func attach(inputs: FireInputs) { self.inputs = inputs }

    /// Function to validate all user inputs
    func validate() -> Bool {
        guard let inputs else { return false }

        if inputs.housingType == .mortgage {
            guard let outstanding = Double(inputs.outstandingMortgageText), outstanding > 0
            else { errorText = "Enter outstanding mortgage balance > 0"; return false }
            
            guard let mortgageYearlyInterest = Double(inputs.mortgageYearlyInterestText), mortgageYearlyInterest >= 0, mortgageYearlyInterest <= 100
            else {
                errorText = "Enter 100 >= yearly mortgage interest rate >= 0"
                return false
            }
            
            guard let mortgageMinimumPayment = Double(inputs.mortgageMinimumPaymentText), mortgageMinimumPayment > 0
            else {
                errorText = "Enter minimum monthly payment > 0"
                return false
            }
        }
        else if inputs.housingType == .rent {
            guard let weeklyRent = Double(inputs.weeklyRentText), weeklyRent >= 0
            else {
                errorText = "Enter weekly rent >= 0"
                return false
            }
        }

        errorText = nil
        return true
    }
}
/// Reprsents the type of housing the user is living in
enum HousingType: String {
    case mortgage, rent
}

/// Represents whether the housing details for the user has been set or not
enum HousingDetailsSet: String {
   case unset, set
}
