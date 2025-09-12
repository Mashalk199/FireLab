//
//  InvestmentView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI
import UIKit
/** In this screen, the user is able to input all of their investment preferences and details. They can specify the investment diversity they will want their portfolio to follow, how much they want to allocate to certain investments with certain growth rates. */
struct InvestmentView: View {
    @EnvironmentObject var inputs: FireInputs
    @State private var goNext = false
    @State private var errorText: String?
    @AccessibilityFocusState private var errorFocused: Bool

    // Function to validate all user inputs
    func validate() -> Bool {
        if !canCalculate {
            errorText = "Please ensure total allocation percentages sum to 100%"
            return false
        }
        // Ensures there are no empty boxes for allocation percentages
        for item in inputs.items {
            if let _ = Double(item.allocationPercent.trimmingCharacters(in: .whitespaces)) {
                continue
            }
            errorText = "Please enter valid percentage allocations"
            return false
        }
        errorText = nil
        return true
    }
    /// This computed property computes the total percentage allocated by the user across all investments displayed.
    var totalPercent: Double {
        inputs.items
            .map { Double($0.allocationPercent.trimmingCharacters(in: .whitespaces)) ?? 0 }
            .reduce(0, +)
    }

    /// Computed property that checks whether the list of investments is not empty and that the total allocated percentages add up to near 100%.
    var canCalculate: Bool {
        !inputs.items.isEmpty && abs(totalPercent - 100) < 0.01
    }
    /// Autocompletes all unfilled allocations with an equal allocation.
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
        
        let remaining = max(0, 100.0 - filledTotal)
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
            .accessibilityLabel("Autocomplete")
            .accessibilityHint("Autocomplete all unfilled allocations with an equal allocation")
            
            if let msg = errorText {
                Text(msg)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 400, alignment: .center)
                    .padding(.horizontal)
                
                    // Accessibility: mark and focus the error
                    .accessibilityLabel("Error: \(msg)")
                    .accessibilityHint("Fix the fields below, then try again.")
                    // read before other content
                    .accessibilitySortPriority(1000)
                    .accessibilityAddTraits(.isStaticText)
                
                    .accessibilityFocused($errorFocused)
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
                            border: .orange,
                            hint: "Add an investment to your list") {
                    AddInvestmentView(currETF: SelectedETF())
                }
                Button {
                    if validate() { goNext = true }
                } label: {
                    SmallButtonView(text: "Calculate FIRE",
                                    fontSize: 16,
                                    icon: "arrow.right.circle",
                                    width: 190,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
                .accessibilityLabel("Calculate FIRE")
                .accessibilityHint(canCalculate ? "Proceed to calculation" : "Disabled until allocations total 100 percent")
            }
            .padding(.bottom, 10)
        }
        .navigationDestination(isPresented: $goNext) {
                    FireResultView(retirementData: RetirementData())
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
            // Make the badge a single accessible element
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Total allocation")
            .accessibilityValue("\(totalPercent, specifier: "%.1f") percent")
            .accessibilityHint("Must reach exactly 100 percent before calculating")
            
        }
        .onChange(of: errorText) {
            if let msg = errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
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
