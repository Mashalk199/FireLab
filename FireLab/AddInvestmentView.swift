//
//  AddInvestmentView.swift
//  FireLab
//
//  Created by YIHAN on 27/8/2025.
//

import SwiftUI
class SelectedETF: ObservableObject {
    @Published var selectedETF: String?
}

struct AddInvestmentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs
    @ObservedObject var currETF: SelectedETF
    
    @State private var tab = 0   // 0: ETF, 1: Bond
    @State private var name = ""
    @State private var amount = ""
    @State private var expected = ""
    @State private var autoCalc = false
    
    var body: some View {
        VStack(spacing: 16) {
            Logo()
                .padding(.top, 8)
            
            Picker("", selection: $tab) {
                Text("ETF").tag(0)
                Text("Bond").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if tab == 0 {
                VStack(spacing: 12) {
                    HStack {
                        Text("Select ETF")
                            .frame(width: 200, alignment: .leading)
                        
                        NavigationLink("Choose →") {
                            ETFSearchView(currETF: currETF)
                        }
                        .frame(width: 150, alignment: .trailing)
                    }
                    .frame(width: 350)
                    
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
                
                RoundedFillButton(title: "Add") {
                    let displayName = tab == 0
                    // Uses nil coalescing operator to set etf name
                    ? (currETF.selectedETF ?? "ETF")
                    : (name.isEmpty ? "Bond #1" : name)
                    
                    inputs.items.append(
                        InvestmentItem(
                            name: displayName,
                            type: tab == 0 ? .etf : .bond,
                            allocationPercent: "",
                            expectedReturn: expected
                        )
                    )
                    currETF.selectedETF = nil
                    print(inputs.items)

                    dismiss()
                }
            }
            .padding(.bottom, 14)
        }
    }
}

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
    }
}

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
