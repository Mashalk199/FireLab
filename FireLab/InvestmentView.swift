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
                    .font(.footnote)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Capsule().stroke(Color.gray.opacity(0.4), lineWidth: 1))
            }.padding(.horizontal)
            
            Text("*Proportions must add up to 100%")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach($inputs.items) { $item in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.lightGray))
                            .frame(width: 215, height: 200)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    if let idx = inputs.items.firstIndex(of: item) {
                                        inputs.items.remove(at: idx)
                                    }
                                } label: {
                                    Image(systemName: "x.circle")
                                        .font(.system(size: 25, weight: .bold))
                                        .padding(10)
                                }
                                
                            }
                            .overlay(
                                ZStack {
                                    VStack {
                                        Text(item.name)
                                            .font(.system(size: 20, weight: .black))
                                            .frame(width: 170, alignment: .leading)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                        HStack {
                                            Text("Investment Portfolio Allocation")
                                                .frame(width:100, alignment: .center)
                                                .lineLimit(nil)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            TextField("%",
                                                      text: $item.allocationPercent)
                                            .keyboardType(.decimalPad)
                                            .padding(.leading, 8)
                                            .frame(width: 80, height: 35)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundColor(Color.white)
                                            )
                                        }
                                    }
                                }
                            )
                    }
                    
                    if inputs.items.isEmpty {
                        Text("No investments yet").foregroundStyle(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding(.top, 6)
            }
            
            HStack(spacing: 14) {
                SmallButton(text: "Add Investment",
                            icon: "plus.circle",
                            width: 180,
                            fgColor: .white,
                            bgColor: .orange,
                            border: .orange) {
                    AddInvestmentView(currETF: SelectedETF())
                }
                SmallButton(text: "Calculate FIRE",
                            fontSize: 16,
                            icon: "arrow.right.circle",
                            width: 190,
                            fgColor: .orange,
                            bgColor: .white,
                            border: .black) {
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
        InvestmentItem(name: "AusGov Bonds", type: .bond),
        InvestmentItem(name: "DB Crude Oil Long Exchange Traded Fund", type: .bond),

    ]
    return NavigationStack {
        InvestmentView()
    }
        .environmentObject(inputs)
}
