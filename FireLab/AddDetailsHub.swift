//
//  AddDetailsHub.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct AddDetailsHub: View {
    var yearlyIncome: Double?
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    @EnvironmentObject var inputs: FireInputs
    var body: some View {
        VStack {
            Logo()
                .padding([.bottom], 20)
            InputField(
                label: "Yearly Income",
                fieldVar: $inputs.yearlyIncomeText,
                placeholder: "$")

            InputField(
                label: "Yearly Non-housing Expenses",
                fieldVar: $inputs.nonHousingText,
                placeholder: "$")
            
                
                Spacer()
            
            }
        
    }
}

#Preview {
    AddDetailsHub(yearlyIncome: nil)
        .environmentObject(FireInputs())
}
