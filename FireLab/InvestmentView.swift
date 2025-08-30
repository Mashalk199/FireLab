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
            Logo().padding(.top, 8)
            
            HStack {
                Text("Autocomplete")
                    .font(.footnote)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                Spacer()
            }.padding(.horizontal)
            
            Text("*Proportions must add up to 100%")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 14) {
                    ForEach($inputs.items) { $item in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 140, height: 90)
                                Text(item.name.uppercased())
                                    .font(.headline)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Investment Portfolio\nAllocation")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                HStack {
                                    TextField("%", text: $item.allocationPercent)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 70, height: 36)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                                }
                            }
                            Spacer()
                            Button {
                                if let idx = inputs.items.firstIndex(of: item) {
                                    inputs.items.remove(at: idx)
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if inputs.items.isEmpty {
                        Text("No investments yet").foregroundStyle(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding(.top, 6)
            }
            
            HStack(spacing: 14) {
                SmallButton(text: "Add Investment", icon: "plus.circle",
                            width: 133, fgColor: .orange, bgColor: .white, border: .black) {
                    AddInvestmentView(currETF: SelectedETF())
                }
                SmallButton(text: "Calculate FIRE", icon: "arrow.right.circle",
                            width: 133, fgColor: .orange, bgColor: .white, border: .black) {
                    FireResultView()
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
        InvestmentItem(name: "AusGov Bonds", type: .bond)
    ]
    return NavigationStack {
        InvestmentView()
    }
        .environmentObject(inputs)
}
