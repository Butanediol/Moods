//
//  Tokens.swift
//
//
//  Created by Butanediol on 9/12/2023.
//

import Fluent
import Vapor

final class AccessToken: Model, Content {
    static let schema = "access_token"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "token_value")
    var tokenValue: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init(id: UUID? = nil, tokenValue: String) {
        self.id = id
        self.tokenValue = tokenValue
    }
    
    init() {}
}

final class RefreshToken: Model, Content {
    static let schema = "refresh_token"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "token_value")
    var tokenValue: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init(id: UUID? = nil, tokenValue: String) {
        self.id = id
        self.tokenValue = tokenValue
    }
    
    init() {}
}
