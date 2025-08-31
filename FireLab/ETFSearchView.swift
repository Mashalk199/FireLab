//
//  ETFSearchView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI

struct ETFSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs
    @ObservedObject var currETF: SelectedETF
    @State private var fileContent: String = "Loading..."
    @State private var query = ""
    

    @State var all = ["VDHG", "VS&P500", "NZAM Nasdaq 100", "ETF"]
    var filtered: [String] {
        guard !query.isEmpty else { return all }
        return all.filter {
            $0.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Logo().padding(.top, 8)
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $query)
                Spacer()
                Image(systemName: "mic.fill").opacity(0.3)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.12)))
            .padding(.horizontal)

            List(filtered, id: \.self) { name in
                Button {
                    currETF.selectedETF = name
                    dismiss()
                }
                label: { Text(name).frame(maxWidth: .infinity, alignment: .leading) }
            }
            .listStyle(.plain)
        }
        .onAppear {
            loadFileContent()
        }
    }
    private func loadFileContent() {
            if let fileURL = Bundle.main.url(forResource: "ETF List", withExtension: "txt") {
                do {
                    let contents = try String(contentsOf: fileURL, encoding: .utf8)
                    fileContent = contents
                    // Parse the file content into an array of ETF names
                    all = contents.components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                } catch {
                    fileContent = "Error loading file: \(error.localizedDescription)"
                    // Fallback to default list if file loading fails
                    all = ["VDHG", "VS&P500", "NZAM Nasdaq 100", "ETF"]
                }
            } else {
                fileContent = "File not found in bundle."
                // Fallback to default list if file not found
                all = ["VDHG", "VS&P500", "NZAM Nasdaq 100", "ETF"]
            }
        }
}

#Preview {
    NavigationStack {
        ETFSearchView(currETF: SelectedETF())
    }
        .environmentObject(FireInputs())
}
