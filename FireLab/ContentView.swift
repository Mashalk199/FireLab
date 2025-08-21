//
//  ContentView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var inputs = FireInputs()
    var body: some View {
        VStack {
            NavigationStack {
                
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
            .environmentObject(inputs)
            
        }
    }
}

#Preview {
    ContentView()
}
