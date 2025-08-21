//
//  AddDetailsHub.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct AddDetailsHub: View {
    @State var yearlyIncome: Double?
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    @EnvironmentObject var inputs: FireInputs
    var body: some View {
        VStack {
                HStack {
                    Text("Yearly Income")
                        .frame(width:200, alignment: .leading)


                    TextField("$",
                              value: $yearlyIncome,
                              formatter: formatter)
                    .frame(width: 150, height: 30)
                    .border(Color.gray)
                }
                .frame(width: 300)
            HStack {
                Text("Yearly Non-housing Expenses")
                    .frame(width:200, alignment: .leading)

                TextField("$",
                          value: $yearlyIncome,
                          formatter: formatter)
                .frame(width: 150, height: 30)
                .border(Color.gray)
            }
            .frame(width: 300)

                let income = yearlyIncome ?? 0
                Text("Your score was \(income).")
                Spacer()
            
            }
        
    }
}

#Preview {
    AddDetailsHub(yearlyIncome: nil)
}
