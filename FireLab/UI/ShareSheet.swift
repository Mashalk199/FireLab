//
//  ShareSheet.swift
//  FireLab
//
//  Created by YIHAN  on 12/10/2025.
//

import SwiftUI
import UIKit

///System Sharing Panel
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    var completion: UIActivityViewController.CompletionWithItemsHandler? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems,
                                          applicationActivities: applicationActivities)
        vc.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
        vc.completionWithItemsHandler = completion
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
