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
        let newAccessToken = AccessToken(tokenValue: response.access_token, expiresIn: response.expires_in)
        try await newRefreshToken.save(on: req.db)
        try await newAccessToken.save(on: req.db)
        return response
    }
    
    app.get("drive") { req async throws -> View in
        let accessToken = try await getAccessToken(app: req.application)
        let items = try await req.application.graphAPIClient.listItems(paths: [], token: accessToken.tokenValue)
        
        return try await req.view.render("index", ["items": items])
    }

    app.get("drive", "**") { req async throws -> View in
        let path = req.parameters.getCatchall()
        let accessToken = try await getAccessToken(app: req.application)
        let items = try await req.application.graphAPIClient.listItems(paths: path, token: accessToken.tokenValue)
        
        items.filter { $0.microsoftGraphDownloadUrl != nil }.forEach{ print($0.microsoftGraphDownloadUrl!) }
        
        print(items)
        
        return try await req.view.render("index", ["items": items])
    }
}
