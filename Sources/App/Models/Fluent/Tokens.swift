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
    
    // Expire after ? seconds
    @Field(key: "expires_in")
    var expiresIn: Int
    
    init(id: UUID? = nil, tokenValue: String, expiresIn: Int) {
        self.id = id
        self.tokenValue = tokenValue
        self.expiresIn = expiresIn
    }
    
    init() {}
    
    // MARK: - Functions
    var expired: Bool {
        guard let createdAt else { return true }
        return Date().timeIntervalSince1970 > createdAt.timeIntervalSince1970 + Double(expiresIn)
    }
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

func getAccessToken(app: Application) async throws -> AccessToken {
    if let lastAccessToken = try await AccessToken.query(on: app.db)
        .sort(\.$createdAt, .descending)
        .first(), !lastAccessToken.expired {
        // Last access token exists and has not expired.
        return lastAccessToken
    } else {
        let oldRefreshToken = try await RefreshToken.query(on: app.db).sort(\.$createdAt, .descending).first()
        let response = try await app.graphAPIClient.refreshAccessToken(
            clientId: oldRefreshToken?.tokenValue ?? app.graphAPIKeys.clientId,
            refreshToken: app.graphAPIKeys.refreshToken,
            clientSecret: app.graphAPIKeys.clientSecret
        )
        let newAccessToken = AccessToken(tokenValue: response.access_token, expiresIn: response.expires_in)
        let newRefreshToken = RefreshToken(tokenValue: response.refresh_token)
        try await app.db.transaction { db in
            try await newAccessToken.save(on: db)
            try await newRefreshToken.save(on: db)
        }
        return newAccessToken
    }
    
}
