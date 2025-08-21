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

//struct InputField : View {
//    var body: some View {
//        var fieldText: String = ""
//        var fieldPlaceholder: String = ""
//        HStack {
//            Text(fieldText)
//                .frame(width:200, alignment: .leading)
//            TextField(fieldPlaceholder,
//                      value: $yearlyIncome,
//                      formatter: formatter)
//            .frame(width: 150, height: 30)
//            .border(Color.gray)
//        }
//        .frame(width: 300)
//    }
//}

