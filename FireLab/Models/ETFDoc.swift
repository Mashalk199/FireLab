//
//  ETFDoc.swift
//  FireLab
//
//  Created by Mashal Ahmad Khan on 1/10/2025.
//


import FirebaseFirestore

struct ETFDoc: Identifiable {
    let id: String
    let symbol: String
    let name: String
    let currency: String
    let exchange: String
    let micCode: String
    let country: String

    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        guard
            let symbol = data["symbol"] as? String,
            let name = data["name"] as? String,
            let currency = data["currency"] as? String,
            let exchange = data["exchange"] as? String,
            let micCode = data["mic_code"] as? String,
            let country = data["country"] as? String
        else { return nil }

        self.id = doc.documentID
        self.symbol = symbol
        self.name = name
        self.currency = currency
        self.exchange = exchange
        self.micCode = micCode
        self.country = country
    }
}
