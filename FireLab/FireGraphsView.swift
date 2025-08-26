//
//  FireGraphsView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI

struct FireGraphsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Logo().padding(.top, 8)
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 140)
                    .overlay(Text("Graph Placeholder").foregroundStyle(.secondary))
                    .padding(.horizontal)
            }
            Spacer()
        }
    }
}
