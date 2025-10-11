//
//  ETFDataService.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 9/10/2025.
//

import Foundation

protocol FinancialDataFetching {
    func fetchTimeSeries(symbol: String, endDate: Date) async throws -> [Double]
}

class FinancialDataService: FinancialDataFetching {
    private let apiKey: String
    
    init() {
        // Load API key from Secrets.plist
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["FinancialAPIKey"] as? String {
            self.apiKey = key
        } else {
            fatalError("Missing FinancialAPIKey in Secrets.plist")
        }
    }
    
    //call the API and construct the endpoint
    func fetchTimeSeries(symbol: String, endDate: Date) async throws -> [Double] {
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Australia/Sydney")
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.nonConformingFloatDecodingStrategy = .throw
        
        let dateStr = formatter.string(from: endDate)
        
        // URLComponents handles encoding and query params
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "api.twelvedata.com"
        comps.path = "/time_series"
        
        comps.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "interval", value: "1day"),
            URLQueryItem(name: "outputsize", value: "501"),
            URLQueryItem(name: "format", value: "JSON"),
            URLQueryItem(name: "end_date", value: dateStr) 
        ]
        
        guard let url = comps.url else {
            throw URLError(.badURL)
        }
        
        // Print full URL for debugging
        print("TwelveData URL:", url.absoluteString)
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let financialData = try decoder.decode(FinancialData.self, from: data)
        var financialArray = financialData.values.map { $0.close }
        // We reverse so that earlier dates appear earlier in array
        financialArray.reverse()
        // Returns array of financial data prices
        return financialArray
    }
}

