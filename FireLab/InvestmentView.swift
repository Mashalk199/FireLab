//
//  InvestmentView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI

struct InvestmentView: View {
    @EnvironmentObject var inputs: FireInputs
    
    var body: some View {
        VStack(spacing: 16) {
            FireLogo().padding(.top, 8)
            
            HStack {
                Text("Autocomplete")
                    .font(.system(size: 12))
                    .padding(.horizontal, 15).padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )

            }.padding(.horizontal)
            
            Text("*Proportions must add up to 100%")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            ScrollView {
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
