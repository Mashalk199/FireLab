//
//  AddLoanView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 23/9/2025.
//

import SwiftUI

struct AddLoanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var inputs: FireInputs
    @State var loanName: String = ""

    var body: some View {
            FireLogo()
            InputField(
                label: "Loan Name",
                fieldVar: $loanName,
                placeholder: "",
            fieldWidth: 200)
        Spacer()
    }
}

#Preview {
    NavigationStack {
        AddLoanView()
            .environmentObject(FireInputs())
            
    }
}
