//
//  InvestmentView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI
import UIKit

// Here we define a gesture enum to determine the position of each investment card during a gesture.



/** In this screen, the user is able to input all of their investment preferences and details. They can specify the investment diversity they will want their portfolio to follow, how much they want to allocate to certain investments with certain growth rates. */
struct InvestmentView: View {
    @EnvironmentObject var inputs: FireInputs
    @StateObject private var vm = InvestmentViewModel() // added VM
    @State private var goNext = false
    @AccessibilityFocusState private var errorFocused: Bool
    @State private var currItem = InvestmentItem()
    @State private var goToInvestment = false

    
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
            
            FormErrorText(
                message: vm.errorText,
                isFocused: $errorFocused
            )
            
            
            ScrollView {
                Text("*Proportions must add up to 100%")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                VStack(spacing: 20) {
                    ForEach($inputs.investmentItems) { $item in
                        InvestmentAllocationCard(item: $item,
                                                 onEdit: {
                                                    currItem = item
                                                    goToInvestment = true
                                                         },
                                                 onDelete: {
                                                     vm.removeItem(item)
                                                 })
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))

                    
                    if inputs.investmentItems.isEmpty {
                        Text("No investments yet").foregroundStyle(.secondary)
                            .padding(.top, 20)
                    }
                }
                .padding(.top, 6)
            }
            
            HStack(spacing: 14) {
                Button {
                        currItem = InvestmentItem()    // fresh item
                        goToInvestment = true               // trigger navigation
                    } label: {
                        SmallButtonView(
                            text: "Add Investment",
                            fontSize: 16,
                            icon: "plus.circle",
                            width: 180,
                            fgColor: .white,
                            bgColor: .orange,
                            border: .orange
                        )
                    }
                    .accessibilityLabel("Add Investment")
                    .accessibilityHint("Add an investment to your list")
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
            FireCalculatingView(
                vm: FireResultViewModel(),
                retirementData: RetirementData()
            )
            .environmentObject(inputs) // keep passing the same inputs
        }
        .navigationDestination(isPresented: $goToInvestment) {
            // We know which item is being edited via editingItemID
            AddInvestmentView(currItem: $currItem)
                .environmentObject(inputs)
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
                .animation(.easeInOut, value: vm.totalPercent)

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
    var onEdit: () -> Void
    var onDelete: () -> Void
    @State private var isHorizontalGesture = false
    @State private var gestureLocked = false

    var maxDragWidth: CGFloat = 70
    // To make animation look better, we use this additional offset variable
    @State private var cardOffsetX: CGFloat = 0
    @State private var trashOffsetX: CGFloat = 0
    @State private var pencilOffsetX: CGFloat = 0
    @State private var pencilBounceToken: Int = 0
    @State private var wasEditCommitted = false
    @State private var deleteBounceToken: Int = 0
    @State private var wasDeleteCommitted = false

    private var editCommitted: Bool {
        pencilOffsetX <= -maxDragWidth * 1.7
    }
    
    private var deleteCommitted: Bool {
        trashOffsetX >= maxDragWidth * 1.7
    }

    
    var body: some View {
        ZStack {
            
            Image(systemName: "trash.circle.fill")
                .offset(x: trashOffsetX)
                .font(.system(size: 35))
                .symbolEffect(.bounce, value: deleteBounceToken)
            Image(systemName: "pencil.circle.fill")
                .offset(x: pencilOffsetX)
                .font(.system(size: 35))
                .symbolEffect(.bounce, value: pencilBounceToken)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.lightGray))
                .frame(width: 215, height: 200)
                .overlay(alignment: .topTrailing) {
                    // Add .destructive annotation as per accessibility HIG
                    Button(role: .destructive) {
                        // Adds animation for specifically when the card is removed
                        withAnimation(.easeInOut) {
                            onDelete()
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
                .offset(x: cardOffsetX)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            let dx = value.translation.width
                            let dy = value.translation.height
                            
                            // Decide intent ONCE at the start of the gesture
                            if !gestureLocked {
                                // Strong horizontal bias to avoid stealing vertical scrolls
                                if abs(dx) > abs(dy) * 1.5 {
                                    isHorizontalGesture = true
                                    gestureLocked = true
                                } else if abs(dy) > abs(dx) {
                                    // Vertical gesture → allow ScrollView to handle it
                                    gestureLocked = true
                                    return
                                } else {
                                    // Not enough information yet
                                    return
                                }
                            }
                            
                            // If horizontal gesture is locked, move the card
                            guard isHorizontalGesture else { return }
                            
                            // If the user drags to the left, offset the hidden trash icon to the right into view
                            if dx < 0 {
                                /*
                                 Move the trash icon to the right at a speed of 1.7x the gesture translation.
                                 Set a maximum travel distance of maxDragWidth * 1.7
                                 */
                                trashOffsetX = min(dx * -1.7, maxDragWidth * 1.7)

                                if deleteCommitted && !wasDeleteCommitted {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    deleteBounceToken += 1
                                }
                                wasDeleteCommitted = deleteCommitted
                            }
                            // Else if the user drags to the right, move the pencil icon to the right
                            else {
                                pencilOffsetX = max(dx * -1.7, -maxDragWidth * 1.7)

                                if editCommitted && !wasEditCommitted {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    pencilBounceToken += 1
                                }
                                wasEditCommitted = editCommitted
                            }
                            
                            let clamped = min(
                                max(dx, -maxDragWidth),
                                maxDragWidth
                            )
                            cardOffsetX = clamped
                        }
                        .onEnded { value in
                            defer {
                                // Reset gesture state for next interaction
                                isHorizontalGesture = false
                                gestureLocked = false
                                wasEditCommitted = false
                                wasDeleteCommitted = false
                            }
                            
                            guard isHorizontalGesture else { return }
                            
                            let dx = value.translation.width
                            
                            if dx <= -maxDragWidth {
                                cardOffsetX = -maxDragWidth
                                
                                withAnimation(.easeInOut) {
                                    onDelete()
                                }
                            } else if dx >= maxDragWidth {
                                withAnimation(.easeInOut) {
                                    cardOffsetX = 0
                                    trashOffsetX = 0
                                    pencilOffsetX = 0

                                }
                                onEdit()
                            } else {
                                // Snap back to center
                                withAnimation(.easeOut) {
                                    cardOffsetX = 0
                                    trashOffsetX = 0
                                    pencilOffsetX = 0
                                }
                            }
                        }
                )
        }
    }
}

#Preview {
    let inputs = FireInputs()
    inputs.investmentItems = [
        InvestmentItem(
            name: "VDHG",
            type: .etf,
            allocationPercent: "60",
            expectedReturn: "4.0",
            etfSnapshot: nil,
            autoCalc: true
        ),
        InvestmentItem(
            name: "FEMS — EM Small Cap AlphaDEX",
            type: .etf,
            allocationPercent: "30",
            expectedReturn: "4.5",
            etfSnapshot:  nil,
            autoCalc: false
        ),
        InvestmentItem(
            name: "RTH — VanEck Retail",
            type: .etf,
            allocationPercent: "10",
            expectedReturn: "2",
            etfSnapshot: nil,
            autoCalc: false
        )
    ]

    return NavigationStack {
        InvestmentView()
    }
    .environmentObject(inputs)
}
