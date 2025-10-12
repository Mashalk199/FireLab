//
//  PastCalculationsView.swift
//  FireLab
//
//  Created by YIHAN  on 7/10/2025.
//

/// Displays a list of the user's past 3 FIRE calculations stored using SwiftData. Allows the user to reapply a previous input snapshot to rerun calculations.

import SwiftUI
import SwiftData

struct PastCalculationsView: View {
    @EnvironmentObject var inputs: FireInputs
    @Environment(\.modelContext) private var modelContext
    // @State private var records: [CalcRecord] = []
    @StateObject private var vm = PastCalculationsViewModel()

    var body: some View {
        VStack {
            FireLogo().padding(.top, 8)
            // Case 1: No previous records
            if vm.rows.isEmpty {
                Text("No past calculations yet").foregroundStyle(.secondary).padding()
            } else {
                // Case 2: Display saved records
                List {
                    ForEach(vm.rows, id: \.id) { row in
                        // Decode both inputs and results from each record
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(row.title)
                                    .font(.headline)
                                Text(row.subtitle)
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            // Reuse the inputs snapshot
                            Button("Reuse inputs") {
                                vm.reuse(row: row, into: inputs)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        // Automatically load the top 3 results when view appears
        .task {
            vm.attach(context: modelContext)                      
            await vm.load()
        }
    }
}
