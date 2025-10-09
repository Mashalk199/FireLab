//
//  FireLabApp.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 19/8/2025.
//

import SwiftUI



import SwiftUI

import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
        
    }
    
}

@main
struct FireLabApp: App {
    //    @StateObject private var inputs = FireInputs()
    @StateObject private var inputs = FireInputs.mockDefaultConfig()
    
    // register app delegate for Firebase setup
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(inputs)
        }
        // to save data
        .modelContainer(for: [CalcRecord.self])
    }
}
