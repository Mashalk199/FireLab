//
//  PortfolioDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI

struct PortfolioDetailsView: View {
    @EnvironmentObject var inputs: FireInputs
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = PortfolioDetailsViewModel()

    var body: some View {
        VStack {
            FireLogo()
                .padding(.bottom, 20)
            Text("Portfolio")
                .font(.headline)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach($inputs.portfolioItems) { $item in
                        PortfolioCard(vm: vm, item: $item)
                    }
                }
                Spacer()
            }

            HStack(spacing: 14) {
                SmallNavButton(text: "Add Loan",
                            icon: "plus.circle",
                            width: 160,
                            fgColor: .white,
                            bgColor: .orange,
                            border: .orange,
                            hint: "Add a loan to your list") {
                    AddPortfolioItemView()
                }

                Button {
                    dismiss()
                } label: {
                    SmallButtonView(text: "Done",
                                    icon: "arrow.left.circle",
                                    width: 140,
                                    fgColor: .orange,
                                    bgColor: .white,
                                    border: .black)
                }
            }
        }
        .onAppear { vm.attach(inputs: inputs) }
        .padding()
    }
}

struct PortfolioCard: View {
    @ObservedObject var vm: PortfolioDetailsViewModel
    @Binding var item: PortfolioItem

    private struct PortfolioCardLabel: View {
        var name: String = ""
        var value: String = ""
        var body: some View {
            Text("Value: \(value)")
                .frame(width: 300, alignment: .center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("\(name) investment value")
                .accessibilityValue(Text("$\(value)"))
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.lightGray))
            .frame(width: 215, height: 200)
            .overlay(alignment: .topTrailing) {
                // Add .destructive annotation as per accessibility HIG
                Button(role: .destructive) {
                    vm.delete(itemID: item.id)
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
                        .font(.system(size: 24, weight: .black))
                        .frame(width: 170, alignment: .center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()

                    let formatted = vm.formattedValue(item.value)
                    PortfolioCardLabel(name: item.name, value: formatted)
                }
                .frame(height: 100)
            )
    }
}

#Preview {
    let inputs = FireInputs()
    inputs.portfolioItems = [
        PortfolioItem(name: "VDHG", type: .etf, value: "3", expectedReturn: "3"),
        PortfolioItem(name: "AusGov Bonds", type: .bond, value: "3", expectedReturn: "3"),
        PortfolioItem(name: "DB Crude Oil Long Exchange Traded Fund", type: .bond, value: "3", expectedReturn: "3")
    ]
    return NavigationStack {
        PortfolioDetailsView()
    }
    .environmentObject(inputs)
}
