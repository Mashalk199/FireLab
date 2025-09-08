//
//  ContentView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var inputs: FireInputs
    
    var body: some View {
        NavigationStack {
            VStack {
                FireLogo()
                    .padding([.bottom], 160)
                NavigationLink(destination: AddDetailsHub()) {
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
