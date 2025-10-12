//
//  FireGraphsViewModel.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 12/10/2025.
//

import Foundation
import SwiftUI

@MainActor
final class FireGraphsViewModel: ObservableObject {
    // MARK: inputs / deps
    let retirementData: RetirementData
    let cal = Calendar.current
    
    // Stable base date so previews don't shift every recompute
    let baseDate: Date = {
        let calendar = Calendar.current
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: comps) ?? now
        return calendar.startOfDay(for: startOfMonth)
    }()
    
    // MARK: config
    let minSpanSeconds: TimeInterval = 28 * 24 * 3600
    
    // MARK: interaction state
    @Published var selectedIndex: Int?
    @Published var xDomain: ClosedRange<Date>?
    @Published var pinchStartDomain: ClosedRange<Date>?
    
    init(retirementData: RetirementData) {
        self.retirementData = retirementData
    }
    
    // MARK: derived series
    var brokerageSeries: [SamplePoint] {
        retirementData.brokerageGrowthData.enumerated().compactMap { i, v in
            guard let date = cal.date(byAdding: .month, value: i, to: baseDate) else { return nil }
            return SamplePoint(date: date, value: v)
        }
    }
    
    // map Date back to index
    func index(for date: Date) -> Int {
        let months = cal.dateComponents([.month], from: baseDate, to: date).month ?? 0
        return max(0, min(months, retirementData.brokerageGrowthData.count - 1))
    }
    
    // current cursor position
    var cursorValueText: String {
        guard let idx = selectedIndex,
              idx < retirementData.brokerageGrowthData.count else { return "-" }
        let v = retirementData.brokerageGrowthData[idx]
        return String(format: "%.0f", v)
    }
    
    // MARK: axis domains
    func visibleYDomain() -> ClosedRange<Double> {
        let dom = xDomain ?? defaultXDomain()
        let valuesInRange = brokerageSeries
            .filter { dom.contains($0.date) }
            .map { $0.value }
        
        guard let minV = valuesInRange.min(),
              let maxV = valuesInRange.max() else {
            return niceYDomain()
        }
        
        let pad = max(1, (maxV - minV) * 0.08)
        return max(0, minV - pad)...(maxV + pad)
    }
    
    func defaultXDomain() -> ClosedRange<Date> {
        guard let first = brokerageSeries.first?.date,
              let last  = brokerageSeries.last?.date else {
            let d0 = baseDate
            let d1 = cal.date(byAdding: .month, value: 1, to: d0) ?? d0.addingTimeInterval(30*24*3600)
            return d0...d1
        }
        return first...last
    }
    
    func niceYDomain() -> ClosedRange<Double> {
        guard let minV = retirementData.brokerageGrowthData.min(),
              let maxV = retirementData.brokerageGrowthData.max() else {
            return 0...1
        }
        let pad = max(1, (maxV - minV) * 0.08)
        return max(0, minV - pad)...(maxV + pad)
    }
    
    func clamped(_ range: ClosedRange<Date>,
                 to limits: ClosedRange<Date>) -> ClosedRange<Date> {
        let lower = max(range.lowerBound, limits.lowerBound)
        let upper = min(range.upperBound, limits.upperBound)
        if upper.timeIntervalSince(lower) < minSpanSeconds {
            let mid = lower.addingTimeInterval(upper.timeIntervalSince(lower) / 2)
            let half = minSpanSeconds / 2
            let l = max(limits.lowerBound, mid.addingTimeInterval(-half))
            let r = min(limits.upperBound, mid.addingTimeInterval(+half))
            return l...r
        }
        return lower...upper
    }
}
