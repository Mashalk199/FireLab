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
    @State private var records: [CalcRecord] = []
    
    var body: some View {
        VStack {
            FireLogo().padding(.top, 8)
            // Case 1: No previous records
            if records.isEmpty {
                Text("No past calculations yet").foregroundStyle(.secondary).padding()
            } else {
                // Case 2: Display saved records
                List {
                    ForEach(records, id: \.id) { r in
                        // Decode both inputs and results from each record
                        if let (snap, res) = Persistence.decode(record: r) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(r.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.headline)
                                    Text("Retires in \(res.workingDays/365)y \( (res.workingDays%365)/30)m · Broker \(Int(res.brokerProp*100))%")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                                Spacer()
                                // Reuse the inputs snapshot
                                Button("Reuse inputs") {
                                    inputs.apply(snapshot: snap)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        // Automatically load the top 3 results when view appears
        .task { records = Persistence.fetchTop3(context: modelContext) }
    }
}
