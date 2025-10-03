//
//  ETFSearchView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI
/** This page allows users to search for an existing ETF from the database by displaying the ETF names in a searchable list. Tapping on any ETF automatically selects it and redirects the user to the AddInvestmentView page.
 */
struct ETFSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs
    @ObservedObject var currETF: SelectedETF
    @State private var fileContent: String = "Loading..."
    @State private var query = ""
    @StateObject private var vm = ETFSearchViewModel()

    /// This is a computed variable storing all ETF names to be displayed, that were either filtered from a user's query, or stores all ETF's when no query has been made.
    private var filtered: [ETFDoc] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return vm.all }
        return vm.all.filter { $0.name.localizedCaseInsensitiveContains(q) || $0.symbol.localizedCaseInsensitiveContains(q) }
    }
    
    
    var body: some View {
        VStack(spacing: 12) {
            FireLogo().padding(.top, 8)
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $query)
                Spacer()
                Image(systemName: "mic.fill").opacity(0.3)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.12)))
            .padding(.horizontal)

            if vm.isLoading {
            ProgressView("Loading ETFs…")
                .padding()
            } else if let err = vm.errorMessage {
                Text(err).foregroundStyle(.red).padding()
            } else {
                List(filtered) { etf in
                    Button {
                        currETF.selectedETF = etf
                        dismiss()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(etf.name)
                            Text("\(etf.symbol) · \(etf.micCode)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .listStyle(.plain)
            }
        }
        .task { await vm.loadOnce() }   // fetch once when the view appears
    }
}

#Preview {
    NavigationStack {
        ETFSearchView(currETF: SelectedETF())
    }
        .environmentObject(FireInputs())
}
