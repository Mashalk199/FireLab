//
//  ETFSearchViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 1/10/2025.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class ETFSearchViewModel: ObservableObject {
    @Published var all: [ETFDoc] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let db = Firestore.firestore()

    /// One-shot fetch; call once when the screen loads.
    func loadOnce() async {
        guard all.isEmpty else { return }        // avoid refetch if already loaded
        isLoading = true
        // defer keyword sets the isLoading false flag to execute once the current scope exists (the current function)
        defer { isLoading = false }

        do {
            let snap = try await db.collection("securities")
                .order(by: "name")
                .getDocuments()

            self.all = snap.documents.compactMap { ETFDoc(doc: $0) }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
