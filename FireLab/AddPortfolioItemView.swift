//
//  AddPortfolioItemView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 29/9/2025.
//

import SwiftUI

struct AddPortfolioItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs
    @State private var tab = PortfolioItemType.nonSuper
    @State var investmentName = ""
    @State var investmentValue = ""
    // Yearly interest rate
    @State var investmentReturn = ""
    @State var superName = ""
    @State var superValue = ""
    @State private var errorText: String?
    @AccessibilityFocusState private var errorFocused: Bool

    /// Function to validate all user inputs
    private func validate() -> Bool {
            
        if tab == .nonSuper {
            if investmentName.isEmpty {
                errorText = "Enter an investment name"
                return false
            }
            
            guard let value = Double(investmentValue), value > 0
            else { errorText = "Enter investment value > 0"; return false }
            
            guard let superYearlyReturn = Double(investmentReturn), superYearlyReturn >= 0, superYearlyReturn <= 100
            else {
                errorText = "Enter 100 >= yearly investment return rate >= 0";
                return false }
        }
        else if tab == .superannuation {
            if superName.isEmpty {
                errorText = "Enter a superannuation name"
                return false
            }
            guard let superValueField = Double(superValue), superValueField > 0
            else {
                errorText = "Enter super value > 0";
                return false }
        }
        
        errorText = nil
        return true
    }
    
    var body: some View {
        VStack {
            FireLogo()
                .padding([.bottom], 20)
            
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
            
            
            Picker("Investment Type", selection: $tab) {
                
                Text("Non-super").tag(PortfolioItemType.nonSuper)
                    .accessibilityLabel("Non-super")
                    .accessibilityHint("Select to enter details about your Non-super investment")
                
                Text("Super").tag(PortfolioItemType.superannuation)
                    .accessibilityLabel("Super")
                    .accessibilityHint("Select to enter details about your Super")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .accessibilityLabel("Select investment type")
            VStack(spacing: 14) {
                if tab == .nonSuper {
                    InputField(
                        label: "Investment Name",
                        fieldVar: $investmentName,
                        placeholder: "Name",
                    )
                    .padding(.top, 15)
                    
                    InputField(
                        label: "Investment Value",
                        fieldVar: $investmentValue,
                        placeholder: "$",
                    )
                    InputField(
                        label: "Expected Yearly Return",
                        fieldVar: $investmentReturn,
                        placeholder: "%",
                    )
                }
                else if tab == .superannuation {
                    InputField(
                        label: "Super Name",
                        fieldVar: $superName,
                        placeholder: "Name",
                    )
                    .padding(.top, 15)
                    
                    InputField(
                        label: "Super Value",
                        fieldVar: $superValue,
                        placeholder: "$",
                    )
                }
            }
            
            Spacer()
            
            HStack(spacing: 14) {
                Button {
                    dismiss()
                } label: {
                    SmallButtonView(text: "Cancel",
                                    icon: "arrow.left.circle",
                                    width: 150,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
                .accessibilityLabel("Cancel adding investment")
                
                
                Button {
                    if validate() {
                        inputs.portfolioItems.append(
                            PortfolioItem(name: investmentName,
                                          // By default, set any non-super investments to ETF type
                                          type: tab == .nonSuper ? InvestmentType.etf : InvestmentType.superannuation,
                                          value: investmentValue,
                                          expectedReturn: investmentReturn)
                        )
                        dismiss()
                    }
                } label: {
                    SmallButtonView(text: "Add",
                                    icon: "checkmark.circle",
                                    width: 133,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
                .accessibilityLabel("Add loan")
                .accessibilityHint("Add loan to your finances")

                
            }
            
        }
        .onChange(of: errorText) {
            if let msg = errorText {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
        .padding()
    }
    private enum PortfolioItemType: String {
        case nonSuper, superannuation
    }
    
}

#Preview {
    AddPortfolioItemView()
}
