//
//  FireGraphsView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

///Display a line chart showing "brokerage account value over time" + area gradient.
///interaction:
///(1) Long press -> drag: Display and move vertical cursors, read out corresponding dates and values
///(2) Pinch-to-zoom: Scales X-axis range centred on current visible area (supports minimum 1-month span, automatically snaps to full range).
///(3) Double-tap to reset

import SwiftUI
import Charts

struct SamplePoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: view
struct FireGraphsView: View {
    @ObservedObject var retirementData: RetirementData
    
    // MARK: configuration
    
    var currentDate = Date()
    var x_years: [String] = []
    
    // Stable base date so previews don't shift every recompute
    private let baseDate: Date = {
        let calendar = Calendar.current
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        let startOfMonth = calendar.date(from: comps) ?? now
        return calendar.startOfDay(for: startOfMonth)
    }()
    private let cal = Calendar.current
    private let minSpanSeconds: TimeInterval = 28 * 24 * 3600
    
    // MARK: interaction
    @State private var selectedIndex: Int?
    @GestureState private var isPressing = false
    @State private var xDomain: ClosedRange<Date>?
    @State private var pinchStartDomain: ClosedRange<Date>?
    
    // MARK: derived series
    var brokerageSeries: [SamplePoint] {
        return retirementData.brokerageGrowthData.enumerated().compactMap { i, v in
            guard let date = cal.date(byAdding: .month, value: i, to: baseDate) else { return nil }
            return SamplePoint(date: date, value: v)
        }
    }
    
    // map Date back to index
    private func index(for date: Date) -> Int {
        let months = cal.dateComponents([.month], from: baseDate, to: date).month ?? 0
        return max(0, min(months, retirementData.brokerageGrowthData.count - 1))
    }
    
    // current cursor position
    private var cursorValueText: String {
        guard let idx = selectedIndex, idx < retirementData.brokerageGrowthData.count else { return "-" }
        let v = retirementData.brokerageGrowthData[idx]
        return String(format: "%.0f", v)
    }
    
    // MARK: body
    var body: some View {
        VStack(spacing: 16) {
            FireLogo().padding(.top, 8)
            
            if brokerageSeries.isEmpty {
                ContentUnavailableView(
                    "No graph data yet",
                    systemImage: "chart.xyaxis.line",
                    description: Text("Run a calculation to see your brokerage projection.")
                )
                .padding()
            } else {
                chartView
                    .padding(.horizontal)
                    .chartOverlay { proxy in
                        overlayGestures(proxy: proxy)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Brokerage projection chart")
                    .accessibilityHint("Long press then drag to explore values by date")
            }
            
            Spacer(minLength: 8)
        }
    }
    
    // MARK: chart content
    @ViewBuilder
    var chartView: some View {
        Chart {
            // broken line
            ForEach(brokerageSeries) { pt in
                LineMark(x: .value("Date", pt.date),
                         y: .value("Value", pt.value))
                .interpolationMethod(.catmullRom)
            }
            // area gradient
            ForEach(brokerageSeries) { pt in
                AreaMark(x: .value("Date", pt.date),
                         y: .value("Value", pt.value))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.accentColor.opacity(0.35),
                                                    .accentColor.opacity(0.0)]),
                        startPoint: .top, endPoint: .bottom
                    )
                )
            }
            // cursor
            if let idx = selectedIndex, idx < brokerageSeries.count {
                let p = brokerageSeries[idx]
                RuleMark(x: .value("Cursor", p.date))
                    .lineStyle(.init(lineWidth: 1.5, dash: [4, 3]))
                    .foregroundStyle(.orange)
                    .annotation(position: .topLeading, spacing: 6) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption).foregroundStyle(.secondary)
                            Text("$\(cursorValueText)")
                                .font(.callout).bold()
                        }
                        .padding(8)
                        .background(.background, in: .rect(cornerRadius: 8))
                        .shadow(radius: 1)
                    }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine().foregroundStyle(.gray.opacity(0.15))
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 2)) {
                AxisGridLine().foregroundStyle(.gray.opacity(0.07))
                AxisValueLabel(format: .dateTime.year())
            }
        }
        .chartLegend(.hidden)
        .chartYScale(domain: visibleYDomain())
        .chartXScale(domain: xDomain ?? defaultXDomain())
        .frame(height: 320)
    }
    
    // MARK: overlay & gestures
    @ViewBuilder
    private func overlayGestures(proxy: ChartProxy) -> some View {
        GeometryReader { geo in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
            
            // double-click to reset the range and clear the cursor
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut) {
                        xDomain = defaultXDomain()
                        selectedIndex = nil
                    }
                }
            
            // pinch-to-zoom
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            if pinchStartDomain == nil {
                                pinchStartDomain = xDomain ?? defaultXDomain()
                            }
                            guard let base = pinchStartDomain else { return }
                            
                            let full = defaultXDomain()
                            let span = base.upperBound.timeIntervalSince(base.lowerBound)
                            let mid  = base.lowerBound.addingTimeInterval(span / 2)
                            
                            let newHalf = max(minSpanSeconds/2, span / (2 * scale))
                            let proposed = mid.addingTimeInterval(-newHalf)...mid.addingTimeInterval(+newHalf)
                            
                            xDomain = clamped(proposed, to: full)
                        }
                        .onEnded { _ in
                            pinchStartDomain = nil
                        }
                )
            
            // long press -> drag
                .gesture(
                    LongPressGesture(minimumDuration: 0.2)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .updating($isPressing) { value, state, _ in
                            if case .first(true) = value { state = true }
                            if case .second(true, _) = value { state = true }
                        }
                        .onChanged { value in
                            switch value {
                            case .first(true):
                                let loc = CGPoint(x: geo.size.width/2, y: 0)
                                if let d: Date = proxy.value(atX: loc.x) { selectedIndex = index(for: d) }
                            case .second(true, let drag):
                                if let drag {
                                    let origin = geo[proxy.plotAreaFrame].origin
                                    let locX = drag.location.x - origin.x
                                    if let d: Date = proxy.value(atX: locX) {
                                        selectedIndex = index(for: d)
                                        UIAccessibility.post(
                                            notification: .announcement,
                                            argument: "Value \(cursorValueText) dollars"
                                        )
                                    }
                                }
                            default: break
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedIndex = nil
                            }
                        }
                )
        }
    }
    
    // MARK: axis domains
    private func visibleYDomain() -> ClosedRange<Double> {
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
    
    private func clamped(_ range: ClosedRange<Date>,
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

#Preview {
    let retirementData = RetirementData()
    retirementData.brokerageGrowthData = [1, 2, 3, 4, 5, 4, 3 ,2, 1]
    return NavigationStack {
        FireGraphsView(retirementData: retirementData)
    }
    .environmentObject(FireInputs())
}
