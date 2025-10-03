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
    @StateObject private var vm = InvestmentViewModel() // added VM
    @State private var goNext = false
    @AccessibilityFocusState private var errorFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            FireLogo().padding(.top, 8)
            
            Button {
                vm.autocompleteAllocations() // moved logic
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
            
            if let msg = vm.errorText { // now reads from VM
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
                    ForEach($inputs.investmentItems) { $item in
                        InvestmentAllocationCard(item: $item, itemList: $inputs.investmentItems)
                    }
                    
                    if inputs.investmentItems.isEmpty {
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
                    if vm.validate() { goNext = true } // moved validation
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
                .accessibilityHint(vm.canCalculate ? "Proceed to calculation" : "Disabled until allocations total 100 percent")
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
                    Text("\(vm.totalPercent, specifier: "%.1f")%") // uses VM
                        .font(.system(size: 13))
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 180)
            // Make the badge a single accessible element
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Total allocation")
            .accessibilityValue("\(vm.totalPercent, specifier: "%.1f") percent")
            .accessibilityHint("Must reach exactly 100 percent before calculating")
        }
        .onAppear { vm.attach(inputs: inputs) } // attach EnvironmentObject
        .onChange(of: vm.errorText) { _, new in   // modern iOS 17 signature
            if let msg = new {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
    }
}

/** This is used in the InvestmentView screen which displays all user-selected investments in a format of a list
 of cards, and each card has a small field inside that lets the user type in a percentage allocation they want to set for
 a particular investment. */
struct InvestmentAllocationCard : View {
    @Binding var item: InvestmentItem
    @Binding var itemList: [InvestmentItem]
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.lightGray))
            .frame(width: 215, height: 200)
            .overlay(alignment: .topTrailing) {
                // Add .destructive annotation as per accessibility HIG
                Button(role: .destructive) {
                    if let idx = itemList.firstIndex(of: item) {
                        itemList.remove(at: idx)
                    }
                } label: {
                    Image(systemName: "x.circle")
                        .font(.system(size: 25, weight: .bold))
                        .padding(10)
                    // Hides this icon from being dictated by voiceover
                        .accessibilityHidden(true)
                }
                .accessibilityLabel("Delete \(item.name) investment")
                .accessibilityHint("Removes this investment from the list")
            }
            .overlay(
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
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.white)
                                TextField("%",
                                          text: $item.allocationPercent)
                                .keyboardType(.decimalPad)
                                .padding(.leading, 8)
                                .accessibilityLabel("\(item.name) investment allocation percentage")
                                .accessibilityValue(
                                    Text(item.allocationPercent.isEmpty
                                         ? "Empty"
                                         : "\(item.allocationPercent) percent")
                                )
                                .accessibilityHint("Edit the allocation percentage")
                                // Adds a clear button to make it easy to clear the allocation of for percentages, improving the user experience
                                HStack {
                                    Spacer()
                                    if !item.allocationPercent.isEmpty {
                                        Button {
                                            item.allocationPercent = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray.opacity(0.6))
                                        }
                                        .padding(.trailing, 8)
                                        .accessibilityLabel("Clear allocation")
                                        .accessibilityHint("Clears the allocation percentage for \(item.name)")
                                        .accessibilityAddTraits(.isButton)
                                    }
                                }
                            }
                            .frame(width: 80, height: 35)
                        }
                    }
                    // Logically groups these views of text and textfields for accessibility
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(Text("\(item.name), Allocation"))
                
            )
    }
}

#Preview {
    let inputs = FireInputs()
    inputs.investmentItems = [
        InvestmentItem(name: "VDHG", type: .etf,  allocationPercent: "", expectedReturn: "3"),
        InvestmentItem(name: "AusGov Bonds", type: .bond, allocationPercent: "", expectedReturn: "3"),
        InvestmentItem(name: "DB Crude Oil Long Exchange Traded Fund", type: .bond, allocationPercent: "50", expectedReturn: "3")
    ]

    return NavigationStack {
        InvestmentView()
    }
    .environmentObject(inputs)
}
