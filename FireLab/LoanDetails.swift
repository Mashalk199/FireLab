//
//  OtherLoanDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI

struct LoanDetails: View {
    @EnvironmentObject var inputs: FireInputs
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        FireLogo()
            .padding(.bottom, 20)
        Text("Loans")
            .font(.headline)
        ScrollView {
            VStack(spacing: 20) {
                ForEach($inputs.loanItems) { $item in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.lightGray))
                        .frame(width: 330, height: 200)
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
                                if let payment = Double(item.minimumPayment) {
                                    Text("Minimum monthly payment: \(payment.formatted(.currency(code: "AUD")))")
                                } else {
                                    Text("Minimum monthly payment: \(item.minimumPayment)")
                                }
                                Text("Growth rate: \(item.interestRate)%")
                                Spacer()
                            }
                        )
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
                AddLoanView()
            }
            
            Button {
                dismiss()
            } label: {
                SmallButtonView(text: "Done",
                                icon: "arrow.left.circle",
                                width: 140,
                                fgColor: .orange,
                                bgColor: .white,
                                border: .black,)
            }
            
        }
    }
}

#Preview {
    let inputs = FireInputs()
    inputs.loanItems = [
        LoanItem(name: "HELP Loan", outstandingBalance: "40000", interestRate: "3.5", minimumPayment: "400"),
        LoanItem(name: "Car Loan", outstandingBalance: "100000", interestRate: "5.5", minimumPayment: "10000"),
    ]
    return NavigationStack {
        LoanDetails()
    }
        .environmentObject(inputs)
}
