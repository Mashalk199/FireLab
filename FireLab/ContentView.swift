//
//  ContentView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("FireLab")
                .font(.system(size: 36, weight: .black))
                .fontWeight(.black)
            // Here we adhere to HIG by using system default colors so that system dark mode management is possible
                .foregroundColor(.orange)
                .padding([.bottom], 160)
            Button(action: {
                
            }) {
                Text("Risky FIRE")
                    .font(.system(size: 36))
                    .frame(width: 353, height: 127)
                    .foregroundColor(.orange)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.orange, lineWidth: 3)
                    )
                    .padding([.bottom], 25)
                
            }
            
            
            
            Button(action: {
                
            }) {
                Text("Standard FIRE")
                    .font(.system(size: 36))
                    .frame(width: 353, height: 127)
                    .foregroundColor(.orange)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.orange, lineWidth: 3)
                    )
                    .padding([.bottom], 25)
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
