//
//  FireLabApp.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

@main
struct FireLabApp: App {
    @StateObject private var inputs = FireInputs()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(inputs)
        }
    }
}
