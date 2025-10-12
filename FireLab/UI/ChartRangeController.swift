//
//  ChartRangeController.swift
//  FireLab
//
//  Created by YIHAN  on 12/10/2025.
//

import Foundation

/// Clamp a requested date range so that:
/// 1) it's inside `limits`
/// 2) its span is at least `minSpan` when possible If the entire `limits` itself is shorter than `minSpan`, then return `limits` directly.

struct ChartRangeController {
    let minSpan: TimeInterval

    func clamped(_ range: ClosedRange<Date>, to limits: ClosedRange<Date>) -> ClosedRange<Date> {
            // Initially clamped to limits
            var lower = max(range.lowerBound, limits.lowerBound)
            var upper = min(range.upperBound, limits.upperBound)
            if upper < lower { swap(&lower, &upper) }

            // If it is sufficiently long, simply return.
            var current = upper.timeIntervalSince(lower)
            if current >= minSpan { return lower ... upper }

            // Length to be added
            var need = minSpan - current

            // add half to each side.
            let spareLeft  = lower.timeIntervalSince(limits.lowerBound)
            let spareRight = limits.upperBound.timeIntervalSince(upper)
            if spareLeft + spareRight < need {
                return limits
            }

            // Distribute evenly to both sides
            let half = need / 2
            let takeLeft  = min(spareLeft,  half)
            let takeRight = min(spareRight, half)
            lower = lower.addingTimeInterval(-takeLeft)
            upper = upper.addingTimeInterval(+takeRight)

            // If there remains any shortfall (due to insufficient space on one side), make up the difference from the other side.
            current = upper.timeIntervalSince(lower)
            need = max(0, minSpan - current)
            if need > 0 {
                let spareLeft2  = lower.timeIntervalSince(limits.lowerBound)
                let spareRight2 = limits.upperBound.timeIntervalSince(upper)
                if spareRight2 > 0 {
                    let extra = min(spareRight2, need)
                    upper = upper.addingTimeInterval(extra)
                }
                need = max(0, minSpan - upper.timeIntervalSince(lower))
                if need > 0, spareLeft2 > 0 {
                    let extra = min(spareLeft2, need)
                    lower = lower.addingTimeInterval(-extra)
                }
            }

            return lower ... upper
        }
    }
