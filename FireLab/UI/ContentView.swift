//
//  ContentView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI
/// In this screen the user can proceed to the first details page where they can enter their details for the app to calculate their retirement options
struct ContentView: View {
    @EnvironmentObject var inputs: FireInputs
    
    var body: some View {
        NavigationStack {
            VStack {
                FireLogo()
                    .padding([.bottom], 160)
                NavigationLink(destination: HubView()) {
                    BigButton(text:"Risky FIRE",
                              hint:"Opens financial independence details page")
                        .padding([.bottom], 25)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FireInputs())
}
