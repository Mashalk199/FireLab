//
//  FireLabApp.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI

@main
struct FireLabApp: App {
    @StateObject var inputs = FireInputs()
    @StateObject var portfolio  = PortfolioModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(inputs)
                .environmentObject(portfolio)
        }
    }
}
