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

/// Enum to pick which ML model to use
enum ForecastModelType {
    case full       // 500-lookback model
    case short      // 60-lookback model
}

/**
 This service provides an interface which allows a user to pass an array of sequential daily ETF data and obtain an autoregressed
 sequence of return predictions for a certain number of time-steps.
 Credit also goes to ChatGPT for building and training the Tensorflow LSTMs
 */
final class MLForecastService: Forecasting {
    private let modelType: ForecastModelType
    private let model: MLModel
    private let lookback: Int

    init(modelType: ForecastModelType = .full) throws {
        self.modelType = modelType

        switch modelType {
        case .full:
            let m = try full_lstm(configuration: .init())
            self.model = m.model
        case .short:
            let m = try lstm_60(configuration: .init())
            self.model = m.model
        }

        // Derive lookback dynamically from model’s input shape
        guard let inputDesc = model.modelDescription.inputDescriptionsByName.values.first,
              let constraint = inputDesc.multiArrayConstraint else {
            throw NSError(domain: "MLForecastService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid model input shape"])
        }
        self.lookback = constraint.shape[1].intValue
    }

    /// Predicts future *percentage returns*
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
        let predsLog = try autoregPredictLogReturns(seedLogRets: seed, steps: steps)

        // Convert log-returns -> simple returns (%) = (exp(r) - 1) * 100
        return predsLog.map {
            let clipped = max(-0.95, min(0.5, Double($0))) // Clamp between -95% and +50%
            return (exp(clipped) - 1.0) * 100.0
        }
    }

    // Core ML Helpers
    private func autoregPredictLogReturns(seedLogRets: [Float], steps: Int) throws -> [Float] {
        var ctx = seedLogRets
        var preds: [Float] = []
        let x = try MLMultiArray(shape: [1, NSNumber(value: lookback), 1], dataType: .float32)
        for i in 0..<lookback { x[i] = NSNumber(value: ctx[i]) }

        for _ in 0..<steps {
            let input: MLFeatureProvider
            switch modelType {
            case .full:
                input = full_lstmInput(input_1: x)
            case .short:
                input = lstm_60Input(input_2: x)
            }

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
            for i in 0..<lookback { x[i] = NSNumber(value: ctx[i]) }
        }

        return preds
    }

    private func makeErr(_ msg: String) -> NSError {
        NSError(domain: "MLForecastService", code: -1,
                userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
