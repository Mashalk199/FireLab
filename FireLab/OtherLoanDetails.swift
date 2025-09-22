//
//  OtherLoanDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI

struct OtherLoanDetails: View {
    @EnvironmentObject var inputs: FireInputs
    var body: some View {
        FireLogo()
            .padding(.bottom, 20)
        ScrollView {
            VStack(spacing: 20) {
                ForEach($inputs.loanItems) { $item in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.lightGray))
                        .frame(width: 300, height: 200)
                        .overlay(alignment: .topTrailing) {
                            // Add .destructive annotation as per accessibility HIG
                            Button(role: .destructive) {
                                if let idx = inputs.loanItems.firstIndex(where: { $0.id == item.id }) {
                                    inputs.loanItems.remove(at: idx)  // <-- fixed
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
                            VStack(spacing: 10) {
                                Text(item.name)
                                    .font(.system(size: 20, weight: .black))
                                    .frame(width: 170, alignment: .center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.top, 40)
                                    .padding(.bottom, 20)
                                if let balance = Double(item.outstandingBalance) {
                                    Text("Outstanding balance: \(balance.formatted(.currency(code: "AUD")))")
                                } else {
                                    Text("Outstanding balance: \(item.outstandingBalance)")
                                }
                                Text("Growth rate: \(item.interestRate)%")
                                Spacer()
                            }
                        )
                }
            }
            Spacer()
        }
    }
}

#Preview {
    let inputs = FireInputs()
    inputs.loanItems = [
        LoanItem(name: "Help Loan", outstandingBalance: "40000", interestRate: "3.5", minimumPayment: "400"),
        LoanItem(name: "Car Loan", outstandingBalance: "100000", interestRate: "5.5", minimumPayment: "1000"),
    ]
    return NavigationStack {
        OtherLoanDetails()
    }
        .environmentObject(inputs)
}
