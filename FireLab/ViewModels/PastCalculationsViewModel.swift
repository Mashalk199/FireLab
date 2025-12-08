//
//  PastCalculationsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 12/10/2025.
//

import Foundation
import SwiftData

@MainActor
final class PastCalculationsViewModel: ObservableObject {

    struct Row: Identifiable {
        let id: UUID
        let title: String        // e.g. "Sep 24, 2025 at 12:54 AM"
        let subtitle: String     // e.g. "Retires in 5y 3m · Broker 60%"
        let snapshot: FireInputsSnapshot
    }

    @Published var rows: [Row] = []

    private var context: ModelContext?

    func attach(context: ModelContext) {
        if self.context == nil { self.context = context }
    }

    /// Loads the top 3 calculation records and maps them into display rows
    func load() async {
        guard let context else { return }
        let records = Persistence.fetchTop3(context: context)

        var built: [Row] = []
        for r in records {
            if let (snap, res) = Persistence.decode(record: r) {
                let years = res.workingMonths / 12
                let months = res.workingMonths % 12
                let brokerPct = Int(res.brokerProp * 100)

                let title = r.createdAt.formatted(date: .abbreviated, time: .shortened)
                let subtitle = "Retires in \(years)y \(months)m · Broker \(brokerPct)%"

                built.append(Row(
                    id: r.id,
                    title: title,
                    subtitle: subtitle,
                    snapshot: snap
                ))
            }
        }
        self.rows = built
    }

    /// Applies the stored snapshot back into live inputs
    func reuse(row: Row, into inputs: FireInputs) {
        inputs.apply(snapshot: row.snapshot)
    }
}
