//
//  ETFSearchView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI

struct ETFSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var app: AppModel
    @ObservedObject var currETF: SelectedETF
    @State private var query = ""

    let all = ["VDHG", "VS&P500", "NZAM Nasdaq 100", "ETF"]
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
    }
}

#Preview {
    NavigationStack {
        ETFSearchView(currETF: SelectedETF())
    }
        .environmentObject(AppModel())
}
