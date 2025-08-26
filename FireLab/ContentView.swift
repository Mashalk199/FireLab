//
//  ContentView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var inputs: FireInputs
    @EnvironmentObject var portfolio: PortfolioModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Logo()
                    .padding([.bottom], 160)
                NavigationLink(destination: AddDetailsHub()) {
                    BigButton(text:"Risky FIRE")
                        .padding([.bottom], 25)
                }
                NavigationLink(destination: AddDetailsHub()) {
                    BigButton(text:"Standard FIRE")
                }
            }
        }
        // Here we attach the environment object of inputs to the root of the entire app, so all screens can write user details to a place that can be accessed for calculations
        .environmentObject(inputs)
        .environmentObject(portfolio)
    }
}

#Preview {
    ContentView()
        .environmentObject(FireInputs())
        .environmentObject(PortfolioModel())
}
