//
//  M0001CreateTokens.swift
//
//
//  Created by Butanediol on 9/12/2023.
//

import Fluent

struct M0001CreateTokens: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(AccessToken.schema)
            .id()
            .field("token_value", .string, .required)
            .create()
        
        try await database.schema(RefreshToken.schema)
            .id()
            .field("token_value", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(AccessToken.schema).delete()
        try await database.schema(RefreshToken.schema).delete()
    }
}
