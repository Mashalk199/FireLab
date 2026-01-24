//
//  SuperDetailsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 23/1/2026.
//

import SwiftUI

@MainActor
final class SuperDetailsViewModel: ObservableObject {
    @Published var superValue: String = ""
    @Published var superReturn: String = ""
    @Published var salary: String = ""
    @Published var superCont: String = ""
    @Published var concessional: String = ""
    @Published var nonConcessional: String = ""
    @Published var retirementMultiplier: String = ""
    
    @Published var errorText: String?
    // gets attached from the View (so EnvironmentObject is available first)
    @Published private var inputs: FireInputs?
    func attach(inputs: FireInputs) { if self.inputs == nil { self.inputs = inputs } }

    // Function to validate all user inputs moved from View
    func validate() -> Bool {
        guard inputs != nil else { return false }
        
        guard let superVal = Double(superValue), superVal >= 0 else { errorText = "Enter super value >= 0"; return false }
        guard let superRetVal = Double(superReturn), superRetVal >= 0, superRetVal <= 100 else { errorText = "Enter 0 <= super expected return <= 100"; return false }
        guard let salaryVal = Double(salary), salaryVal >= 0 else { errorText = "Enter salary >= 0"; return false }
        guard let superContVal = Double(superCont), superContVal >= 0, superContVal <= 100 else { errorText = "Enter 0 <= employer super rate <= 100"; return false }
        if !concessional.isEmpty {
            guard let concessionalVal = Double(concessional), concessionalVal >= 0 else { errorText = "Enter concessional contribution >= 0"; return false }
        }
        if !nonConcessional.isEmpty {
            guard let nonConcessionalVal = Double(nonConcessional), nonConcessionalVal >= 0 else { errorText = "Enter non-concessional contribution >= 0"; return false }
        }
        if !retirementMultiplier.isEmpty {
            guard let multiplierVal = Double(retirementMultiplier), multiplierVal >= 0 else { errorText = "Enter retirement spending % >= 0"; return false }
        }
        
        errorText = nil
        return true
    }
}

