import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }
    
    app.get("refresh") { req async throws -> RefreshAccessTokenResponse in
        let response = try await req.application.graphAPIClient.refreshAccessToken(
            clientId: req.application.graphAPIKeys.clientId,
            refreshToken: req.application.graphAPIKeys.refreshToken,
            clientSecret: req.application.graphAPIKeys.clientSecret
        )
        let newRefreshToken = RefreshToken(tokenValue: response.refresh_token)
        let newAccessToken = AccessToken(tokenValue: response.access_token)
        try await newRefreshToken.save(on: req.db)
        try await newAccessToken.save(on: req.db)
        return response
    }

    app.get("hello") { req async throws -> [DriveItem] in
        guard let accessToken = try await AccessToken.query(on: req.db).first() else {
            throw Abort(.custom(code: 404, reasonPhrase: "Access token not found."))
        }
        return try await req.application.graphAPIClient.listItems(paths: ["Sync", "Rime"], token: accessToken.tokenValue)
    }

    try app.register(collection: TodoController())
}
