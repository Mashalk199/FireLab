//
//  InvestmentView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI

struct InvestmentView: View {
    @EnvironmentObject var inputs: FireInputs
    var totalPercent: Double {
        inputs.items
            .map { Double($0.allocationPercent.trimmingCharacters(in: .whitespaces)) ?? 0 }
            .reduce(0, +)
    }

    //AddInvestment - it is equal to 100%
    var canCalculate: Bool {
        !inputs.items.isEmpty && abs(totalPercent - 100) < 0.0001
    }
    // Autocomplete all unfilled allocations with an equal allocation
    func autocompleteAllocations() {
        guard !inputs.items.isEmpty else { return }
        let filledTotal = inputs.items
                .compactMap { Double($0.allocationPercent.trimmingCharacters(in: .whitespaces)) }
                .reduce(0, +)

        // Filter indices for all investment items which don't have an allocation entered
        let emptyIdxs = inputs.items.indices.filter {
            inputs.items[$0].allocationPercent.trimmingCharacters(in: .whitespaces).isEmpty
        }

        // If nothing to fill or no room left, exit
        guard !emptyIdxs.isEmpty else { return }
        
        var remaining = max(0, 100.0 - filledTotal)
        // If the total proportion assigned is higher than 100%, no autocomplete happens
        guard remaining > 0 else { return }
        let even = remaining / Double(emptyIdxs.count)
        // Assign evenly (1 decimal), last one gets the remainder to reach 100.0
        var allocated = 0.0
        for (pos, idx) in emptyIdxs.enumerated() {
            if pos < emptyIdxs.count - 1 {
                let v = (even * 10).rounded() / 10
                inputs.items[idx].allocationPercent = String(format: "%.1f", v)
                allocated += v
            } else {
                let last = max(0, remaining - allocated)
                let roundedLast = (last * 10).rounded() / 10
                inputs.items[idx].allocationPercent = String(format: "%.1f", roundedLast)
            }
        }
    }
    var body: some View {
        VStack(spacing: 16) {
            FireLogo().padding(.top, 8)
            
            Button {
                autocompleteAllocations()
            } label : {
                HStack {
                    Text("Autocomplete")
                        .font(.system(size: 12))
                        .padding(.horizontal, 15).padding(.vertical, 9)
                        .foregroundColor(.white)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )

                }.padding(.horizontal)
            }
            
            
            
            
            ScrollView {
                Text("*Proportions must add up to 100%")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                VStack(spacing: 20) {
                    ForEach($inputs.items) { $item in
                        InvestmentAllocationCard(item: $item, itemList: $inputs.items)
                    }
                    
                    if inputs.items.isEmpty {
                        Text("No investments yet").foregroundStyle(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding(.top, 6)
            }
            
            HStack(spacing: 14) {
                SmallNavButton(text: "Add Investment",
                            icon: "plus.circle",
                            width: 180,
                            fgColor: .white,
                            bgColor: .orange,
                            border: .orange) {
                    AddInvestmentView(currETF: SelectedETF())
                }
                SmallNavButton(text: "Calculate FIRE",
                            fontSize: 16,
                            icon: "arrow.right.circle",
                            width: 190,
                            fgColor: .orange,
                            bgColor: .white,
                            border: .black) {
                    FireResultView(retirementData: RetirementData())
                }
            }
            .padding(.bottom, 10)
        }
        .overlay(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 60, height: 60)
                VStack {
                    Text("Total")
                        .font(.system(size: 13))
                    Text("\(totalPercent, specifier: "%.1f")%")
                        .font(.system(size: 13))

                }
                
            }
            .padding(.trailing, 20)
            .padding(.bottom, 180)
            
        }
    }
    
    private func binding(for item: InvestmentItem) -> Binding<InvestmentItem> {
        guard let idx = inputs.items.firstIndex(of: item) else {
            return .constant(item)
        }
        return $inputs.items[idx]
    }
}

#Preview {
    let inputs = FireInputs()
    inputs.items = [
        InvestmentItem(name: "VDHG", type: .etf),
        InvestmentItem(name: "AusGov Bonds", type: .bond),
        InvestmentItem(name: "DB Crude Oil Long Exchange Traded Fund", type: .bond),
    ]
    return NavigationStack {
        InvestmentView()
    }
        .environmentObject(inputs)
}
