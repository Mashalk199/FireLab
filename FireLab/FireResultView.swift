//
//  FireResultView.swift
//  FireLab
//
//  Created by YIHAN  on 27/8/2025.
//

import SwiftUI

struct FireResultView: View {
    var years: Int = 22
    var months: Int = 4
    var portfolioTarget: String = "1,634,780.93"

    var body: some View {
        VStack(spacing: 20) {
            Logo().padding(.top, 8)

            Text("\(years) years")
                .font(.system(size: 44, weight: .bold))
                .padding(.top, 10)
            Text("\(months) Months\nuntil you reach financial independence")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Text("Your portfolio will reach")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            Text("$\(portfolioTarget)")
                .font(.system(size: 34, weight: .black))

            Spacer()

            HStack(spacing: 14) {
                SmallButton(text: "View Graphs", icon: "arrow.right.circle",
                            width: 133, fgColor: .white, bgColor: .orange, border: .black.opacity(0.2)) {
                    //FireGraphsView()
                }
                SmallButton(text: "Home", icon: "arrow.clockwise.circle",
                            width: 133, fgColor: .orange, bgColor: .white, border: .black) {
                    ContentView()
                }
            }
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    NavigationStack { FireResultView() }
}
