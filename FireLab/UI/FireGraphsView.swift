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

/// This view displays the interactive graphs for the financial journey of the user. The graphs have gestures and recieve data from the FireResults view.
struct FireGraphsView: View {
    @ObservedObject var retirementData: RetirementData
    
    // MARK: configuration
    
    var currentDate = Date()
    var x_years: [String] = []
    
    // ViewModel (MVVM)
    @StateObject private var vm: FireGraphsViewModel
    
    init(retirementData: RetirementData) {
        self._retirementData = ObservedObject(wrappedValue: retirementData)
        _vm = StateObject(wrappedValue: FireGraphsViewModel(retirementData: retirementData))
    }
    
    // MARK: interaction (now lives in VM)
    @GestureState private var isPressing = false
    
    // MARK: derived series
    var brokerageSeries: [SamplePoint] { vm.brokerageSeries }
    
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
            if let idx = vm.selectedIndex, idx < brokerageSeries.count {
                let p = brokerageSeries[idx]
                RuleMark(x: .value("Cursor", p.date))
                    .lineStyle(.init(lineWidth: 1.5, dash: [4, 3]))
                    .foregroundStyle(.orange)
                    .annotation(position: .topLeading, spacing: 6) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption).foregroundStyle(.secondary)
                            Text("$\(vm.cursorValueText)")
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
        .chartYScale(domain: vm.visibleYDomain())
        .chartXScale(domain: vm.xDomain ?? vm.defaultXDomain())
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
                        vm.xDomain = vm.defaultXDomain()
                        vm.selectedIndex = nil
                    }
                }
            
            // pinch-to-zoom
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            if vm.pinchStartDomain == nil {
                                vm.pinchStartDomain = vm.xDomain ?? vm.defaultXDomain()
                            }
                            guard let base = vm.pinchStartDomain else { return }
                            
                            let full = vm.defaultXDomain()
                            let span = base.upperBound.timeIntervalSince(base.lowerBound)
                            let mid  = base.lowerBound.addingTimeInterval(span / 2)
                            
                            let newHalf = max(vm.minSpanSeconds/2, span / (2 * scale))
                            let proposed = mid.addingTimeInterval(-newHalf)...mid.addingTimeInterval(+newHalf)
                            
                            vm.xDomain = vm.clamped(proposed, to: full)
                        }
                        .onEnded { _ in
                            vm.pinchStartDomain = nil
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
                                if let d: Date = proxy.value(atX: loc.x) { vm.selectedIndex = vm.index(for: d) }
                            case .second(true, let drag):
                                if let drag {
                                    let origin = geo[proxy.plotAreaFrame].origin
                                    let locX = drag.location.x - origin.x
                                    if let d: Date = proxy.value(atX: locX) {
                                        vm.selectedIndex = vm.index(for: d)
                                        UIAccessibility.post(
                                            notification: .announcement,
                                            argument: "Value \(vm.cursorValueText) dollars"
                                        )
                                    }
                                }
                            default: break
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                vm.selectedIndex = nil
                            }
                        }
                )
        }
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
