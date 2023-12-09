//
//  GraphResponse.swift
//
//
//  Created by Butanediol on 9/12/2023.
//

import Vapor

struct GraphResponse<V: Codable>: Codable {
    let odataContext: String
    let microsoftGraphTips: String?
    let value: V
    
    enum CodingKeys: String, CodingKey {
        case odataContext = "@odata.context"
        case microsoftGraphTips = "@microsoft.graph.tips"
        case value
    }
}
