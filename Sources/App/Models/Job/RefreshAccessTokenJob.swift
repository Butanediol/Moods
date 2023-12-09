//
//  RefreshAccessTokenJob.swift
//
//
//  Created by Butanediol on 9/12/2023.
//

import Vapor
import Queues

struct RefreshAccessTokenJob: AsyncScheduledJob {
    
    func run(context: QueueContext) async throws {
        let refreshToken = try await RefreshToken.query(on: context.application.db)
            .sort(\.$createdAt, .descending)
            .first()
        let response = try await context.application.graphAPIClient.refreshAccessToken(
            clientId: context.application.graphAPIKeys.clientId,
            refreshToken: refreshToken?.tokenValue ?? context.application.graphAPIKeys.refreshToken,
            clientSecret: context.application.graphAPIKeys.clientId
        )
        let newRefreshToken = RefreshToken(tokenValue: response.refresh_token)
        let newAccessToken = AccessToken(tokenValue: response.access_token, expiresIn: response.expires_in)
        try await newRefreshToken.save(on: context.application.db)
        try await newAccessToken.save(on: context.application.db)
    }
}
