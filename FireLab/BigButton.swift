//
//  Buttons.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import Foundation
import SwiftUI

struct BigButton : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
        
    }
}
