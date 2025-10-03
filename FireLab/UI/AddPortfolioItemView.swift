//
//  AddPortfolioItemView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 29/9/2025.
//

import SwiftUI

/// This SwiftUI view allows the user to add details of a portfolio item
/// (either a non-super investment or a superannuation). It validates input
/// and appends the new item to FireInputs.
struct AddPortfolioItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs

    @StateObject private var vm = AddPortfolioItemViewModel()
    @AccessibilityFocusState private var errorFocused: Bool

    var body: some View {
        VStack {
            FireLogo()
                .padding([.bottom], 20)

            // Here we display the error message if it has been set.
            if let msg = vm.errorText {
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
            
            Picker("Investment Type", selection: $vm.tab) {
                Text("Non-super").tag(AddPortfolioItemViewModel.PortfolioItemType.nonSuper)
                    .accessibilityLabel("Non-super")
                    .accessibilityHint("Select to enter details about your Non-super investment")
                
                Text("Super").tag(AddPortfolioItemViewModel.PortfolioItemType.superannuation)
                    .accessibilityLabel("Super")
                    .accessibilityHint("Select to enter details about your Super")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .accessibilityLabel("Select investment type")
            
            VStack(spacing: 14) {
                if vm.tab == .nonSuper {
                    InputField(
                        label: "Investment Name",
                        fieldVar: $vm.investmentName,
                        placeholder: "Name"
                    )
                    .padding(.top, 15)
                    
                    InputField(
                        label: "Investment Value",
                        fieldVar: $vm.investmentValue,
                        placeholder: "$"
                    )
                    
                    InputField(
                        label: "Expected Yearly Return",
                        fieldVar: $vm.investmentReturn,
                        placeholder: "%"
                    )
                }
                else if vm.tab == .superannuation {
                    InputField(
                        label: "Super Name",
                        fieldVar: $vm.superName,
                        placeholder: "Name"
                    )
                    .padding(.top, 15)
                    
                    InputField(
                        label: "Super Value",
                        fieldVar: $vm.superValue,
                        placeholder: "$"
                    )
                }
            }
            
            Spacer()
            
            HStack(spacing: 14) {
                Button {
                    dismiss()
                } label: {
                    SmallButtonView(
                        text: "Cancel",
                        icon: "arrow.left.circle",
                        width: 150,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black
                    )
                }
                .accessibilityLabel("Cancel adding investment")
                
                Button {
                    if vm.addIfValid() {
                        dismiss()
                    } else {
                        errorFocused = true
                    }
                } label: {
                    SmallButtonView(
                        text: "Add",
                        icon: "checkmark.circle",
                        width: 133,
                        fgColor: .orange,
                        bgColor: .white,
                        border: .black
                    )
                }
                .accessibilityLabel("Add loan")
                .accessibilityHint("Add loan to your finances")
            }
        }
        .onAppear { vm.attach(inputs: inputs) }
        .onChange(of: vm.errorText) { _, new in
            if let msg = new {
                UIAccessibility.post(notification: .announcement, argument: "Error: \(msg)")
                // Jump to the accessibility focus state in the error message above
                errorFocused = true
            }
        }
        .padding()
    }
}

#Preview {
    AddPortfolioItemView()
        .environmentObject(FireInputs())
}
