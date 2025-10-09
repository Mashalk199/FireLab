//
//  FireResultView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 5/10/2025.
//

import SwiftUI
import Foundation

/// This object stores the data that is to be either displayed in the FireResultView screen or sent to the FireGraphsView page.
final class RetirementData: ObservableObject {
    @Published var brokerageGrowthData: [Double] = []
    @Published var retirementData: Result = Result(
        workingDays: 0,
        retirementDate: Date(),
        brokerProp: 0.5,
        monthlyBrokerContribution: 0,
        monthlySuperContribution: 0,
        brokerageBalanceAtRetirement: 0,
        superBalanceAtRetirement: 0,
        debtClearDays: 0,
        remainingDebts: []
    )
}

/// This struct stores only the data that is to be displayed in the FireResultView page to the user
struct Result: Codable {
    let workingDays: Int
    let retirementDate: Date
    let brokerProp: Double
    let monthlyBrokerContribution: Double
    let monthlySuperContribution: Double
    let brokerageBalanceAtRetirement: Double
    let superBalanceAtRetirement: Double

    // If `remainingDebts` is non-empty we stopped in Phase A (debts not fully cleared).
    let debtClearDays: Int
    //let remainingDebts: [(name: String, balance: Double)]
    let remainingDebts: [DebtRemnant]
}

/** This page displays the results of the retirement calculation performed by the app. It displays the date the user will retire, the value the superannuation and brokerage fund will be at retirement, as well as the monthly contribution that is necessary for both super and brokerage in order to achieve that goal. */
struct FireResultView: View {
    @ObservedObject var retirementData: RetirementData
    @ObservedObject var vm: FireResultViewModel
    let initialResult: Result

    var body: some View {
        let r = initialResult

        VStack(spacing: 20) {
            FireLogo().padding(.top, 8)

            // 1) If debts remain, tell the user why we stopped and what’s left.
            if !r.remainingDebts.isEmpty {
                Text("We stopped early because debts weren’t fully cleared.")
                    .foregroundStyle(.red)
                    .font(.headline)

                let yearsDebt = r.debtClearDays / 365
                let monthsDebt = (r.debtClearDays % 365) / 30
                Text("Time spent servicing debts so far: \(yearsDebt) years \(monthsDebt) months")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Remaining debts:")
                        .font(.headline)
                    ForEach(Array(r.remainingDebts.enumerated()), id: \.offset) { _, d in
                        Text("\(d.name): $\(String(format: "%.0f", d.balance))")
                    }
                }
                .padding(.top, 8)

                Spacer()

                // Keep the buttons
                HStack(spacing: 14) {
                    SmallNavButton(text: "Home", icon: "arrow.clockwise.circle",
                                   width: 150, fgColor: .orange, bgColor: .white, border: .black, hint: "Returns to home page") {
                        ContentView()
                    }
                }
            } else {
                // 2) Debts have cleared, show results
                let years  = r.workingDays / 365
                let months = (r.workingDays % 365) / 30

                Text("\(years) years")
                    .font(.system(size: 44, weight: .bold))
                    .padding(.top, 10)

                Text("\(months) Months\nuntil you reach financial independence")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                // Small banner: how long it took to clear debts (if any)
                if r.debtClearDays > 0 {
                    let y = r.debtClearDays / 365
                    let m = (r.debtClearDays % 365) / 30
                    Text("Debts cleared in \(y) years \(m) months before investing phase.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Text("Retirement date: \(r.retirementDate.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundStyle(.secondary)

                VStack(spacing: 6) {
                    Text("Brokerage at retirement: $\(String(format: "%.0f", r.brokerageBalanceAtRetirement))")

                    Text("Super at retirement: $\(String(format: "%.0f", r.superBalanceAtRetirement))")
                }
                .font(.headline)

                VStack(spacing: 4) {
                    Text("Proportion to Brokerage: \(String(format: "%.2f%%", r.brokerProp * 100))")
                        .foregroundStyle(.secondary)

                    Text("Recommended Monthly Contribution To Brokerage: $\(String(format: "%.0f", r.monthlyBrokerContribution))")

                    Text("Recommended Monthly Contribution To Super: $\(String(format: "%.0f", r.monthlySuperContribution))")
                }
                .frame(width: 350)

                Spacer()

                HStack(spacing: 14) {
                    SmallNavButton(text: "View Graphs", icon: "arrow.right.circle",
                                   width: 150, fgColor: .white, bgColor: .orange, border: .black.opacity(0.2), hint: "Opens graphs page") {
                        FireGraphsView(retirementData: retirementData)
                    }
                    SmallNavButton(text: "Home", icon: "arrow.clockwise.circle",
                                   width: 150, fgColor: .orange, bgColor: .white, border: .black, hint: "Returns to home page") {
                        ContentView()
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }
}
