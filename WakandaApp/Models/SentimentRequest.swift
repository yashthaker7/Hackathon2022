//
//  SentimentRequest.swift
//  WakandaApp
//
//  Created by SOTSYS302 on 02/04/22.
//

import UIKit

struct SentimentRequest: Codable, RequestParameterable {
    
    let documentText: String
    let privateKey = "AE70769A-B670-4131-A8F0-D81DBED40C07"
    let secret = "wakanda"
    
    enum CodingKeys: String, CodingKey {
        case documentText = "DocumentText"
        case privateKey = "PrivateKey"
        case secret = "Secret"
    }
    
    init(text: String) {
        self.documentText = text
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(documentText, forKey: .documentText)
        try container.encode(privateKey, forKey: .privateKey)
        try container.encode(secret, forKey: .secret)
    }
}

struct SentimentResponse: Decodable {
    
    var docSentimentResultString: String
    var docSentimentValue: Double = 0
    
    enum CodingKeys: String, CodingKey {
        case docSentimentResultString = "DocSentimentResultString"
        case docSentimentValue = "DocSentimentValue"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        docSentimentResultString = try values.decodeIfPresent(String.self, forKey: .docSentimentResultString) ?? "Neutral"
        docSentimentValue = try values.decodeIfPresent(Double.self, forKey: .docSentimentValue) ?? 0
    }
    
    var sentimentResult: String {
        return docSentimentResultString.capitalized
    }
    
    var getSentimentColor: UIColor {
        if docSentimentResultString == "negative" {
            return UIColor(hexRGB: "#F73A54") ?? .white
        } else if docSentimentResultString == "positive" {
            return UIColor(hexRGB: "#2BC26C") ?? .white
        }
        return UIColor(hexRGB: "#3A82F7") ?? .white
    }
    
    var getBackgroundSentimentColor: UIColor {
        if docSentimentResultString == "negative" {
            return UIColor(hexRGB: "#FFF5F6") ?? .white
        } else if docSentimentResultString == "positive" {
            return UIColor(hexRGB: "#F6FFFA") ?? .white
        }
        return UIColor(hexRGB: "#F5F9FF") ?? .white
    }
    
    var getPercentage: String {
        return String(format:"%.2f", docSentimentValue * 100) + "%"
    }
}

