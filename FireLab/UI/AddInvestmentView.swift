//
//  AddInvestmentView.swift
//  FireLab
//
//  Created by YIHAN on 27/8/2025.
//

import SwiftUI
import UIKit


/** This screen allows users to add an investment of ETF or bond type to their portfolio that they want to invest into. Users can either select an ETF from the provided list or create their own bond that they are investing in.
 
    There is also an additional option for users to toggle a feature where the app calculates the expected yearly return for them using machine learning.
 */
struct AddInvestmentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs

    @StateObject private var vm: AddInvestmentViewModel

    @AccessibilityFocusState private var errorFocused: Bool
    @Binding private var currItem: InvestmentItem

    // take SelectedETF and pass it to the VM
    init(currItem: Binding<InvestmentItem>) {
        // This is really complicated, i think the issue with details not prefilling has got to do with the wrapped value not updating in this init, where something like  self.currItem = currItem.wrappedValue needs to happen
        _currItem = currItem
        _vm = StateObject(wrappedValue: AddInvestmentViewModel(currItem: currItem.wrappedValue))
    }

    var body: some View {
        VStack(spacing: 16) {
            FireLogo()
                .padding(.top, 8)

            if let msg = vm.errorText {
                Text(msg)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 400, alignment: .center)
                    .padding(.horizontal)
                    .accessibilityLabel("Error: \(msg)")
                    .accessibilityHint("Fix the fields below, then try again.")
                    .accessibilitySortPriority(1000)
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityFocused($errorFocused)
            }

            Picker("Investment type", selection: $vm.tab) {
                Text("ETF").tag(0)
                    .accessibilityLabel("Exchange-traded fund")
                    .accessibilityHint("Select to enter details about an ETF investment")
                Text("Bond").tag(1)
                    .accessibilityLabel("Bond")
                    .accessibilityHint("Select to enter details about a bond investment")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .accessibilityLabel("Select investment type")

            if vm.tab == 0 {
                VStack(spacing: 12) {
                    if let selectedETF = currItem.etfSnapshot {
                        VStack {
                            HStack {
                                Text("Symbol: \(selectedETF.symbol)")
                            }
                        }
                    }
                    SmallNavButton(
                        text: "Select ETF",
                        fontSize: 18,
                        icon: "arrow.right.circle",
                        width: 180,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black,
                        hint: "Add an investment to your list",
                        height: 60
                    ) {
                        ETFSearchView(currItem: $currItem)
                    }
                    .padding([.top, .bottom], 20)

                    //TODO: convert FieldRow and Toggle to common Components component
                    FieldRow(
                        label: "Expected Yearly After-Tax Return",
                        text: $vm.expectedEtfRet,
                        placeholder: "%"
                    )

                    Toggle(
                        "Enable machine learning for return predictions",
                        isOn: $vm.autoCalc
                    )
                    .padding(.horizontal)
                    .accessibilityLabel("Let FireLab handle yearly return")
                    .accessibilityValue(vm.autoCalc ? "true" : "false")
                }
            } else {
                VStack(spacing: 12) {
                    FieldRow(
                        label: "Bond Name (Optional)",
                        text: $vm.bondName,
                        placeholder: "Bond #1"
                    )
                    FieldRow(
                        label: "Expected Yearly After-Tax Return",
                        text: $vm.expectedBondRet,
                        placeholder: "%"
                    )
                }
            }

            Spacer()

            HStack(spacing: 24) {
                RoundedBorderButton(title: "Cancel") {
                    dismiss()
                }
                .accessibilityLabel("Cancel adding investment")

                RoundedFillButton(title: "Add") {
                    if vm.addInvestmentIfValid(currItem: currItem) {
                        dismiss()
                    } else {
                        errorFocused = true
                    }
                }
                .accessibilityLabel("Add investment")
            }
            .padding(.bottom, 14)
        }
        // attach EnvironmentObject after the view exists
        .onAppear { vm.attach(inputs: inputs) }
        .onChange(of: vm.errorText) { _, new in
            if let msg = new {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                errorFocused = true
            }
        }
    }
}

/// This is a component that has a label and a field for the user to input numerical data
struct FieldRow: View {
    var label: String
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 200, alignment: .leading)

            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .frame(width: 150, height: 35)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray.opacity(0.5))
                )
        }
        .frame(width: 350, alignment: .leading)
        .accessibilityLabel(label)
        .accessibilityValue(text.isEmpty ? "Empty" : text)
    }
}

/// This is a cancel navigation button
struct RoundedBorderButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.orange)
                .frame(width: 133, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(.black, lineWidth: 1)
                )
        }
    }
}
/// This is a filled in "add" navigation button
struct RoundedFillButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .frame(width: 133, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.orange)
                )
        }
    }
}

#Preview {
    NavigationStack {
        AddInvestmentView(
            currItem: .constant(
                FireInputs.mockDefaultConfig().investmentItems[0]
            )
        )
        .environmentObject(FireInputs.mockDefaultConfig())
    }
}
