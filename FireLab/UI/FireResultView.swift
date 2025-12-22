//
//  FireResultView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 5/10/2025.
//

import SwiftUI
import Foundation
import SwiftData

private struct URLBox: Identifiable {
    let id = UUID()
    let url: URL
}

/// This object stores the data that is to be either displayed in the FireResultView screen or sent to the FireGraphsView page.
final class RetirementData: ObservableObject {
    @Published var brokerageGrowthData: [Double] = []
    @Published var retirementData: Result = Result(
        workingMonths: 0,
        retirementDate: Date(),
        brokerProp: 0.5,
        monthlyBrokerContribution: 0,
        monthlySuperContribution: 0,
        brokerageBalanceAtRetirement: 0,
        superBalanceAtRetirement: 0,
        debtClearMonths: 0,
        remainingDebts: [],
        brokerageSeries: []
    )
}

/// This struct stores only the data that is to be displayed in the FireResultView page to the user
struct Result: Codable {
    // Total working duration until retirement, expressed in months instead of days
    let workingMonths: Int
    let retirementDate: Date
    let brokerProp: Double
    let monthlyBrokerContribution: Double
    let monthlySuperContribution: Double
    let brokerageBalanceAtRetirement: Double
    let superBalanceAtRetirement: Double
    
    // If `remainingDebts` is non-empty we stopped in Phase A (debts not fully cleared).
    // Previously this was in days; now we track it in months for the monthly simulation
    let debtClearMonths: Int
    
    // let remainingDebts: [(name: String, balance: Double)]
    let remainingDebts: [DebtRemnant]
    
    // for graph
    let brokerageSeries: [Double]
}

/** This page displays the results of the retirement calculation performed by the app. It displays the date the user will retire, the value the superannuation and brokerage fund will be at retirement, as well as the monthly contribution that is necessary for both super and brokerage in order to achieve that goal. */
struct FireResultView: View {
    @ObservedObject var retirementData: RetirementData
    @ObservedObject var vm: FireResultViewModel
    let initialResult: Result
    
    @State private var shareURL: URLBox? = nil
    @State private var previewURL: URLBox? = nil
    @State private var showPreview = false
    
    var body: some View {
        let r = initialResult
        
        VStack(spacing: 20) {
            FireLogo().padding(.top, 8)
            
            // 1) If debts remain, tell the user why we stopped and what’s left.
            if !r.remainingDebts.isEmpty {
                Text("We stopped early because debts weren’t fully cleared.")
                    .foregroundStyle(.red)
                    .font(.headline)
                
                let years = r.workingMonths / 12
                let months = r.workingMonths % 12
                Text("Time spent servicing debts so far: \(years) years \(months) months")
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
                    Button {
                        do { let url = try buildPDFURL(for: r)
                            shareURL = URLBox(url: url) } catch { print("Share failed:", error) }
                    } label: {
                        SmallButtonView(
                            text: "Share",
                            fontSize: 20,
                            icon: "square.and.arrow.up",
                            width: 150,
                            fgColor: .white,
                            bgColor: .blue,
                            border: .blue
                        )
                    }
                    .accessibilityLabel("Share retirement calculation results")
                    .accessibilityHint("Enable system sharing")
                    .buttonStyle(.plain)
                    SmallNavButton(text: "Home", icon: "arrow.clockwise.circle",
                                   width: 150, fgColor: .orange, bgColor: .white, border: .black, hint: "Returns to home page") {
                        ContentView()
                    }
                }
            } else {
                // 2) Debts have cleared, show results
                let years = r.workingMonths / 12
                let months = r.workingMonths % 12
                
                Text("\(years) years")
                    .font(.system(size: 44, weight: .bold))
                    .padding(.top, 10)
                
                Text("\(months) Months\nuntil you reach financial independence")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                // Small banner: how long it took to clear debts (if any)
                if r.debtClearMonths > 0 {
                    let y = r.debtClearMonths / 12
                    let m = r.debtClearMonths % 12
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
                                   width: 150, fgColor: .white, bgColor: .orange,
                                   border: .black.opacity(0.2), hint: "Opens graphs page") {
                        FireGraphsView(retirementData: retirementData)
                    }
                    
                    SmallNavButton(text: "Home", icon: "arrow.clockwise.circle",
                                   width: 150, fgColor: .orange, bgColor: .white, border: .black, hint: "Returns to home page") {
                        ContentView()
                    }
                }
                
                HStack {
                    Button {
                        do { let url = try buildPDFURL(for: r)
                            shareURL = URLBox(url: url) } catch { print("Share failed:", error) }
                    } label: {
                        SmallButtonView(text: "Share", fontSize: 20, icon: "square.and.arrow.up",
                                        width: 150, fgColor: .white, bgColor: .blue, border: .blue, height: 54)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Share retirement calculation results")
                    .accessibilityHint("Open iOS share sheet")
                }
                
                HStack {
                    Button("Preview PDF") {
                        do { let url = try buildPDFURL(for: r)
                            previewURL = URLBox(url: url)
                            showPreview = true }
                        catch { print("Preview failed:", error) }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 12)
            }
        }
        
        .sheet(item: $shareURL) { box in
            ShareSheet(activityItems: [box.url])
        }
        
        .sheet(isPresented: $showPreview) {
            if let box = previewURL {
                QuickLookPreview(url: box.url)
            }
        }
    }
    
    //Merge PDF content
    private func summaryText(for r: Result) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        
        let debts: String = {
            if r.remainingDebts.isEmpty { return "None" }
            return r.remainingDebts.map { "\($0.name)=\(Int($0.balance))" }.joined(separator: ", ")
        }()
        
        return """
        FIRE Calculation Summary
        ------------------------
        Retirement date: \(df.string(from: r.retirementDate))
        Working months required: \(r.workingMonths)
        
        Monthly Contributions:
          • Brokerage: $\(Int(r.monthlyBrokerContribution))
          • Superannuation: $\(Int(r.monthlySuperContribution))
        
        Balances at Retirement:
          • Brokerage: $\(Int(r.brokerageBalanceAtRetirement))
          • Super (at age 60): $\(Int(r.superBalanceAtRetirement))
        
        Debt repayment duration: \(r.debtClearMonths) months
        Remaining debts: \(debts)
        
        Generated by FireLab
        """
    }
    
    //Generate PDF
    private func buildPDFURL(for r: Result) throws -> URL {
        let fileName = "FireLab-\(Date.now.formatted(.dateTime.year().month().day().hour().minute())).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let data = PDFGenerator.makePDF(from: summaryText(for: r))
        
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        
        try data.write(to: url, options: .atomic)
        return url
    }
}
