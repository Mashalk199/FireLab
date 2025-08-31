//
//  FireLogo.swift
//  FireLab
//
//  Created by YIHAN  on 31/8/2025.
//
import SwiftUI

struct FlameTitleLayout: Layout {
    var spacing: CGFloat = 10
    
    //calculate the size
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard subviews.count == 2 else { return .zero }
        let emblem = subviews[0].sizeThatFits(.unspecified)
        let title  = subviews[1].sizeThatFits(.unspecified)
        
        let horizontalW = emblem.width + spacing + title.width
        let horizontalH = max(emblem.height, title.height)
        
        if let maxW = proposal.width, horizontalW > maxW {
            return CGSize(width: max(emblem.width, title.width),
                          height: emblem.height + spacing + title.height)
        } else {
            return CGSize(width: horizontalW, height: horizontalH)
        }
    }
    
    //place emblem + title
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 2 else { return }
        let emblem = subviews[0].sizeThatFits(.unspecified)
        let title  = subviews[1].sizeThatFits(.unspecified)
        
        let horizontalW = emblem.width + spacing + title.width
        let useVertical = (horizontalW > bounds.width)
        
        if useVertical {
            //emblem above, title below
            let totalH = emblem.height + spacing + title.height
            let startY = bounds.midY - totalH/2
            subviews[0].place( at: CGPoint(x: bounds.midX, y: startY + emblem.height/2),
                               anchor: .center,
                               proposal: ProposedViewSize(emblem))
            subviews[1].place( at: CGPoint(x: bounds.midX, y: startY + emblem.height + spacing + title.height/2),
                               anchor: .center,
                               proposal: ProposedViewSize(title))
        } else {
            //emblem on the left, title on the right
            let totalW = horizontalW
            let startX = bounds.midX - totalW/2
            subviews[0].place( at: CGPoint(x: startX + emblem.width/2, y: bounds.midY),
                               anchor: .center,
                               proposal: ProposedViewSize(emblem))
            subviews[1].place( at: CGPoint(x: startX + emblem.width + spacing + title.width/2, y: bounds.midY),
                               anchor: .center,
                               proposal: ProposedViewSize(title))
        }
    }
}

//emblem
struct FireEmblem: View {
    var size: CGFloat = 44
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [.orange, .red, .orange]),
                        center: .center
                    )
                )
            Image(systemName: "flame.fill")
                .font(.system(size: size * 0.52, weight: .black))
                .foregroundStyle(.white)
                .shadow(radius: 1)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

//logo
struct FireLogo: View {
    var title: String = "FireLab"
    var emblemSize: CGFloat = 44
    var spacing: CGFloat = 10
    
    var body: some View {
        FlameTitleLayout(spacing: spacing) {
            FireEmblem(size: emblemSize)
            Text(title)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(.orange)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .padding(.top, 4)
    }
}

#Preview {
    VStack(spacing: 24) {
        FireLogo()
        FireLogo(emblemSize: 36, spacing: 8)
        FireLogo(title: "FireLab — Retirement Planner", emblemSize: 36)
    }
    .padding()
}

