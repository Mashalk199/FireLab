//
//  Buttons.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import Foundation
import SwiftUI

struct Logo : View {
    var body: some View {
        Text("FireLab")
            .font(.system(size: 36, weight: .black))
            .fontWeight(.black)
        // Here we adhere to HIG by using system default colors so that system dark mode management is possible
            .foregroundColor(.orange)
    }
}
struct BigButton : View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 36))
            .frame(width: 353, height: 127)
            .foregroundColor(.orange)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.black, lineWidth: 1)
            )
    }
}

struct InputField : View {
    var label: String
    @Binding var fieldVar: String
    var placeholder: String
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width:200, alignment: .leading)
            
            TextField(placeholder,
                      text: $fieldVar)
            .keyboardType(.decimalPad)
            .frame(width: 150, height: 35)
            .border(Color.gray)
        }
        .frame(width: 300)
    }
}

// This medium button is used on screen 2, the AddDetailsHub
struct MediumButton : View {
    var text: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .foregroundColor(Color.orange)
            
            Text(text)
                .font(.system(size: 20))
                .foregroundColor(.white)
            
            HStack {
                Spacer()
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(.white)
                    .padding(.trailing, 7)
                    .font(.system(size: 40))
            }
        }
            .frame(width: 350, height: 61)
    }
}

