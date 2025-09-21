//
//  HousingDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI

struct HousingDetails: View {
    @EnvironmentObject var inputs: FireInputs
    @State private var tab = HousingType.mortgage
    
    
    var body: some View {
        VStack {
            FireLogo()
                .padding([.bottom], 20)
            
            Text("Are you renting or do you have a mortgage?")
            
            Picker("Housing type", selection: $tab) {
                
                Text("Mortgage").tag(HousingType.mortgage)
                    .accessibilityLabel("Mortgage")
                    .accessibilityHint("Select to enter details about your mortgage")
                
                Text("Rent").tag(HousingType.rent)
                    .accessibilityLabel("Rent")
                    .accessibilityHint("Select to enter details about your rental house")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .accessibilityLabel("Select housing type")
            
            VStack(spacing: 14) {
                if tab == .mortgage {
                    InputField(label: "Outstanding Mortgage Balance",
                               fieldVar: $inputs.outstandingMortgageText,
                               placeholder: "$",
                    )
                    .padding(.top, 15)
                    
                    InputField(label: "Mortgage Yearly Interest Rate",
                               fieldVar: $inputs.mortgageYearlyInterestText,
                               placeholder: "%",
                    )
                    
                }
                else if tab == .rent {
                    InputField(label: "Weekly Rent",
                               fieldVar: $inputs.monthlyRentText,
                               placeholder: "$",
                    )
                    .padding(.top, 15)
                    
                }
            }
            
            Spacer()
        }
        
    }
    
    private enum HousingType: String {
        case mortgage, rent
    }
}


#Preview {
    NavigationStack { HousingDetails() }
        .environmentObject(FireInputs())
}
