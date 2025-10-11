//
//  FireCalculatingView.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 5/10/2025.
//

import SwiftUI
import SwiftData

struct FireCalculatingView: View {
    @EnvironmentObject var inputs: FireInputs
    @StateObject var vm: FireResultViewModel
    @ObservedObject var retirementData: RetirementData
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if vm.isCalculating {
                VStack(spacing: 16) {
                    FireLogo().padding(.top, 8)
                        .navigationBarBackButtonHidden(true)
                    
                    ProgressView("Calculating…")
                        .progressViewStyle(.circular)
                        .padding(.top, 12)
                    Text("This can take up to 10 minutes")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding()
            } else if let res = vm.result {
                // Hand off to the result view — no recalculation happens here
                FireResultView(retirementData: retirementData, vm: vm, initialResult: res)
                    .task {
                        retirementData.brokerageGrowthData = res.brokerageSeries
                        Persistence.saveLatest3(context: modelContext, inputs: inputs, result: res)
                    }
            } else {
                VStack(spacing: 12) {
                    FireLogo().padding(.top, 8)
                    Text(vm.errorText ?? "Something went wrong.")
                        .foregroundStyle(.red)
                    Button("Try again") {
                        vm.run(inputs: inputs)
                    }
                }
            }
        }
        .task {
            // Start once when pushed
            if vm.result == nil && !vm.isCalculating {
                vm.run(inputs: inputs)
            }
        }
    }
}
