//
//  MLForecastService.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 10/10/2025.
//

import Foundation
import CoreML

/// Defines a contract for forecasting future returns (as percentages).
protocol Forecasting {
    func predictReturns(closes: [Double], steps: Int) throws -> [Double]
}

/// Enum kept for compatibility, but the monthly version uses a single model.
enum ForecastModelType {
    case monthly
}

/**
 This service provides an interface which allows a user to pass an array of sequential monthly ETF data and obtain an autoregressed
 sequence of return predictions for a certain number of time-steps.
 Credit also goes to ChatGPT for building and training the Tensorflow LSTMs
 */
final class MLForecastService: Forecasting {
    private let model: MLModel
    private let lookback: Int

    init(modelType: ForecastModelType = .monthly) throws {
        // Single monthly model – both "full" and "short" cases from the old daily version now map to this.
        let m = try lstm_monthly(configuration: .init())
        self.model = m.model

        // Derive lookback dynamically from the model’s input shape.
        // Supports both (1, lookback, 1) and (lookback, 1) style shapes.
        guard let inputDesc = model.modelDescription.inputDescriptionsByName.values.first,
              let constraint = inputDesc.multiArrayConstraint else {
            throw NSError(domain: "MLForecastService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid model input shape"])
        }

        let shape = constraint.shape
        let lb: Int
        switch shape.count {
        case 3:
            // e.g. [1, lookback, 1]
            lb = shape[1].intValue
        case 2:
            // e.g. [lookback, 1]
            lb = shape[0].intValue
        case 1:
            // e.g. [lookback]
            lb = shape[0].intValue
        default:
            throw NSError(domain: "MLForecastService", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "Unsupported input rank \(shape.count)"])
        }

        self.lookback = lb
    }

    /// Predicts future *percentage returns* (monthly).
    func predictReturns(closes: [Double], steps: Int) throws -> [Double] {
        // last known prices must be ascending
        guard closes.count >= 2 else { throw makeErr("Not enough price data") }

        // compute log-returns (time-ascending)
        let logRets = zip(closes.dropFirst(), closes.dropLast()).map { log($0 / $1) }
        guard logRets.count >= lookback else {
            throw makeErr("Need \(lookback) returns, have \(logRets.count)")
        }

        // Take last N log-returns as input seed
        let seed = Array(logRets.suffix(lookback)).map(Float.init)

        // Autoregress in log-return space (monthly)
        let predsLog = try autoregPredictLogReturns(seedLogRets: seed, steps: steps)

        // Convert log-returns -> simple returns (%) = (exp(r) - 1) * 100
        return predsLog.map {
            let clipped = max(-0.95, min(0.50, Double($0))) // Clamp between -95% and +50%
            return (exp(clipped) - 1.0) * 100.0
        }
    }

    // Core ML Helpers
    private func autoregPredictLogReturns(seedLogRets: [Float], steps: Int) throws -> [Float] {
        var ctx = seedLogRets
        var preds: [Float] = []

        guard let inputDesc = model.modelDescription.inputDescriptionsByName.values.first,
              let constraint = inputDesc.multiArrayConstraint else {
            throw makeErr("Invalid model input shape")
        }

        let x = try MLMultiArray(shape: constraint.shape, dataType: .float32)

        // Fill the underlying buffer linearly with the seed context.
        for i in 0..<lookback {
            x[i] = NSNumber(value: ctx[i])
        }

        for _ in 0..<steps {
            // Single monthly model – input feature is "input_1".
            let input = lstm_monthlyInput(input_1: x)

            let out = try model.prediction(from: input)
            guard let y = out.featureValue(for: out.featureNames.first!)?.multiArrayValue,
                  y.count > 0 else {
                throw makeErr("Empty model output")
            }

            let r = Float(truncating: y[0])
            preds.append(r)

            // slide window (autoregression)
            ctx.removeFirst()
            ctx.append(r)
            for i in 0..<lookback {
                x[i] = NSNumber(value: ctx[i])
            }
        }

        return preds
    }

    private func makeErr(_ msg: String) -> NSError {
        NSError(domain: "MLForecastService", code: -1,
                userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
