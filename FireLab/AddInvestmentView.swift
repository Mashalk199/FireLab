//
//  AddInvestmentView.swift
//  FireLab
//
//  Created by YIHAN on 27/8/2025.
//

import SwiftUI
import UIKit
/// This object is used to pass information from the ETFSearchView screen about the selected ETF to this AddInvestmentView screen
class SelectedETF: ObservableObject {
    @Published var selectedETF: ETFDoc?
}

/** This screen allows users to add an investment of ETF or bond type to their portfolio that they want to invest into. Users can either select an ETF from the provided list or create their own bond that they are investing in.
 
    There is also an additional option for users to toggle a feature where the app calculates the expected yearly return for them using machine learning.
 */
struct AddInvestmentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs
    @ObservedObject var currETF: SelectedETF
    
    @State private var tab = 0   // 0: ETF, 1: Bond
    @State private var name = ""
    @State private var expected = ""
    @State private var autoCalc = false
    @State private var errorText: String?
    @AccessibilityFocusState private var errorFocused: Bool

    /// Function to validate user input, ensuring an ETF is selected or that a bond name is set
    func validate() -> Bool {
        if tab == 0 {
            guard let _ = currETF.selectedETF
            else {
                errorText = "Please select an ETF"; return false }
        }
        else if tab == 1 {
            if name == "" {
                errorText = "Please create a bond name"
                return false
            }
        }
        
        guard let expectedETFReturn = Double(expected),
                expectedETFReturn <= 100, expectedETFReturn > 0
        else {
            errorText = "Enter 100 >= Expected Return > 0"; return false }
            
        errorText = nil
        return true
    }
    
    var body: some View {
        VStack(spacing: 16) {
            FireLogo()
                .padding(.top, 8)
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
            Picker("Investment type", selection: $tab) {
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

            
            if tab == 0 {
                VStack(spacing: 12) {
                    SmallNavButton(text: "Select ETF",
                                fontSize: 18,
                                icon: "arrow.right.circle",
                                width: 180,
                                fgColor: .orange,
                                bgColor: .white,
                                border: .black,
                                hint: "Add an investment to your list",
                                height: 60,
                    ) {
                        ETFSearchView(currETF: currETF)
                    }
                    .padding([.top, .bottom], 20)
                            
                    
                    
                    FieldRow(
                        label: "Expected Yearly After-Tax Return",
                        text: $expected,
                        placeholder: "%"
                    )
                    .opacity(autoCalc ? 0.4 : 1)
                    .disabled(autoCalc)
                    
                    Toggle(
                        "Let FireLab calculate expected yearly return (upcoming feature)",
                        isOn: $autoCalc
                    )
                    .disabled(true)
                    .padding(.horizontal)
                    .accessibilityLabel("Let FireLab handle yearly return")
                    .accessibilityValue(autoCalc ? "true" : "false")
                }
            } else {
                VStack(spacing: 12) {
                    FieldRow(
                        label: "Bond Name (Optional)",
                        text: $name,
                        placeholder: "Bond #1"
                    )
                    
                    
                    FieldRow(
                        label: "Expected Yearly After-Tax Return",
                        text: $expected,
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
                    
                    if validate() {
                        let displayName = tab == 0
                        // Uses nil coalescing operator to set etf name
                        ? (currETF.selectedETF?.name ?? "ETF")
                        : (name.isEmpty ? "Bond #1" : name)
                        
                        inputs.investmentItems.append(
                            InvestmentItem(
                                name: displayName,
                                type: tab == 0 ? .etf : .bond,
                                allocationPercent: "",
                                expectedReturn: expected
                            )
                        )
                        currETF.selectedETF = nil
                        
                        dismiss()
                    }
                }
                .accessibilityLabel("Add investment")
                
            }
            .padding(.bottom, 14)
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
        AddInvestmentView(currETF: SelectedETF())
            .environmentObject(FireInputs())
            
    }
}
