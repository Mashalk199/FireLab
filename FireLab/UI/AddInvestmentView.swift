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
        // TODO: Fix the current poor handling of currItem being passed to the viewmodel
        _currItem = currItem
        let currentItem = currItem.wrappedValue
        _vm = StateObject(wrappedValue: AddInvestmentViewModel(currItem: currentItem))
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
                Text("Super").tag(2)
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

                    InputField(
                        label: "Expected Yearly After-Tax Return",
                        fieldVar: $vm.expectedEtfRet,
                        placeholder: "%",
                        helpText: nil,
                        fieldWidth: 150
                    )

                    ToggleRow(
                        label: "Enable machine learning for return predictions",
                        isOn: $vm.autoCalc
                    )
                    .accessibilityLabel("Let FireLab handle yearly return")
                    .accessibilityValue(vm.autoCalc ? "true" : "false")

                    ToggleRow(
                        label: "I already own this investment",
                        isOn: $vm.ownsCurrently
                    )

                    if vm.ownsCurrently {
                        InputField(
                            label: "Current Investment Value",
                            fieldVar: $vm.currentValue,
                            placeholder: "$",
                            helpText: nil,
                            fieldWidth: 150
                        )
                    }
                }
            } else if vm.tab == 1 {
                VStack(spacing: 12) {
                    InputField(
                        label: "Bond Name (Optional)",
                        fieldVar: $vm.bondName,
                        placeholder: "Bond #1",
                        helpText: nil,
                        fieldWidth: 150
                    )
                    InputField(
                        label: "Expected Yearly After-Tax Return",
                        fieldVar: $vm.expectedBondRet,
                        placeholder: "%",
                        helpText: nil,
                        fieldWidth: 150
                    )

                    ToggleRow(
                        label: "I already own this investment",
                        isOn: $vm.ownsCurrently
                    )

                    if vm.ownsCurrently {
                        InputField(
                            label: "Current Investment Value",
                            fieldVar: $vm.currentValue,
                            placeholder: "$",
                            helpText: nil,
                            fieldWidth: 150
                        )
                    }
                }
            } else if vm.tab == 2 {
                InputField(
                    label: "Super Name",
                    fieldVar: $vm.superName,
                    placeholder: "Name"
                )
                .padding(.top, 15)
                
                InputField(
                    label: "Super Value",
                    fieldVar: $vm.currentValue,
                    placeholder: "$"
                )
            }

            Spacer()

            HStack(spacing: 24) {

                Button {
                    dismiss()
                } label: {
                    SmallButtonView(
                        text: "Cancel",
                        fontSize: 18,
                        icon: nil,
                        width: 150,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black,
                        height: 56
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Cancel adding investment")

                Button {
                    if vm.addInvestmentIfValid(currItem: currItem) {
                        dismiss()
                    } else {
                        errorFocused = true
                    }
                } label: {
                    SmallButtonView(
                        text: "Add",
                        fontSize: 18,
                        icon: "checkmark.circle",
                        width: 150,
                        fgColor: .white,
                        bgColor: .orange,
                        border: .orange,
                        height: 56
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add investment")
            }
            .padding(.bottom, 14)
        }
        // attach EnvironmentObject after the view exists
        .onAppear {
            vm.attach(inputs: inputs)
            vm.ownsCurrently = !vm.currentValue.isEmpty
        }
        .onChange(of: vm.errorText) { _, new in
            if let msg = new {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                errorFocused = true
            }
        }
        .onChange(of: vm.ownsCurrently) { _, newValue in
            if !newValue {
                vm.currentValue = ""
            }
        }
    }
}


struct ToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(label)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
                .frame(width: CGFloat(200), alignment: .leading)
                .padding(.leading, 22)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .padding(.trailing, 22)
        }
        .padding(.vertical, 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
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
