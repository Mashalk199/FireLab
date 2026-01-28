//
//  OtherLoanDetails.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 22/8/2025.
//

import SwiftUI
/**
 Here the user can add any and all loans that they have outstanding balances in, and can specify the loan responsibilities like the minimum monthly payment
 */
struct LoanDetailsView: View {
    @EnvironmentObject var inputs: FireInputs
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = LoanDetailsViewModel()
    @State var currItem = LoanItem()
    @State private var goToLoan = false


    var body: some View {
        VStack {
            FireLogo()
                .padding(.bottom, 20)
            
            Text("Loans")
                .font(.headline)
                .padding(.bottom, 5)
            
            
            Text("Include your mortgage, car loans, student loans, and any other debts.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 350)
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 20) {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 0)
                    // NOTE: kept your binding-based iteration;
                    // the cell now calls back into the VM for deletion.
                    ForEach($inputs.loanItems) { $item in
                        LoanCard(
                            item: $item,
                            maxDragWidth: 70,
                            onEdit: {
                                currItem = item
                                goToLoan = true
                            },
                            onDelete: {
                                vm.removeItem(item)
                            }
                        )
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    
                }
                Spacer()
            }
            
            HStack(spacing: 14) {
                Button {
                    goToLoan = true
                } label: {
                    SmallButtonView(text: "Add Loan",
                                    icon: "plus.circle",
                                    width: 160,
                                    fgColor: .white,
                                    bgColor: .orange,
                                    border: .orange,
                                    hint: "Add a loan to your list")
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
            .onAppear { vm.attach(inputs: inputs) } // attach EnvironmentObject
            .navigationDestination(isPresented: $goToLoan) {
                // We know which item is being edited via editingItemID
                AddLoanView(currItem: $currItem)
                    .environmentObject(inputs)
            }
        }
    }
}

/// Loan card for displaying the details of all user-entered loans
struct LoanCard : View {
    @Binding var item: LoanItem
    var maxDragWidth: CGFloat
    var onEdit: () -> Void
    var onDelete: () -> Void

    
    var body: some View {
        ItemCard(
            rectWidth: 215,
            rectHeight: 200,
            maxDragWidth: maxDragWidth,
            deleteAccLabel: "Delete \(item.name) loan",
            deleteAccHint: "Removes \(item.name) from your debt list",
            onEdit: onEdit,
            onDelete: onDelete
        ) {
            VStack(spacing: 12) {

                // Loan name
                Text(item.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.top, 28)

                Divider()

                // Key figures
                VStack(alignment: .leading, spacing: 6) {

                    HStack {
                        Text("Balance")
                            .foregroundColor(.primary.opacity(0.75))

                        Spacer()

                        if let balance = Double(item.outstandingBalance.trimmingCharacters(in: .whitespacesAndNewlines)) {
                            Text(balance.formatted(
                                .currency(code: "AUD")
                                    .precision(.fractionLength(0))
                            ))
                            .bold()
                        } else {
                            Text(item.outstandingBalance)
                        }
                    }

                    HStack {
                        Text("Min / month")
                            .foregroundColor(.primary.opacity(0.75))

                        Spacer()

                        if let payment = Double(item.minimumPayment) {
                            Text(payment.formatted(
                                .currency(code: "AUD")
                                    .precision(.fractionLength(0))
                            ))
                        } else {
                            Text(item.minimumPayment)
                        }
                    }

                    HStack {
                        Text("Interest")
                            .foregroundColor(.primary.opacity(0.75))

                        Spacer()

                        Text("\(item.interestRate)%")
                    }
                }
                .font(.subheadline)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}


#Preview {
    let inputs = FireInputs()
    inputs.loanItems = [
        LoanItem(name: "HELP Loan", outstandingBalance: "40000", interestRate: "3.5", minimumPayment: "400"),
        LoanItem(name: "Car Loan", outstandingBalance: "100000", interestRate: "5.5", minimumPayment: "10000"),
        LoanItem(name: "Car Loan", outstandingBalance: "100000", interestRate: "5.5", minimumPayment: "10000"),
        LoanItem(name: "Car Loan", outstandingBalance: "100000", interestRate: "5.5", minimumPayment: "10000"),
    ]
    return NavigationStack {
        LoanDetailsView()
    }
    .environmentObject(inputs)
}
