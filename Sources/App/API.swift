//
//  API.swift
//
//
//  Created by Butanediol on 9/12/2023.
//

import Vapor

class GraphAPIClient {
    static let baseURL = "https://graph.microsoft.com/v1.0"
    
    let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    /// List items in user's drive
    func listItems(paths: [String], token: String) async throws -> [DriveItem] {
        let path = [
            "/me/drive/root",
            paths.reduce("", { partialResult, nextPath in
                return "\(partialResult)/\(nextPath)"
            }),
            "/children"
        ].joined(separator: ":")
        
        let response = try await client.get(
            URI(string: GraphAPIClient.baseURL + path),
            headers: HTTPHeaders([
                ("Authorization", "Bearer \(token)")
            ]))
        
        let graphResponse = try response.content.decode(GraphResponse<[DriveItem]>.self)
        
        return graphResponse.value
    }
    
    func refreshAccessToken(clientId: String, refreshToken: String, clientSecret: String) async throws -> RefreshAccessTokenResponse {
        let uri = URI(string: "https://login.microsoftonline.com/common/oauth2/v2.0/token")
        
        
        let response = try await client.post(
            uri,
            headers: HTTPHeaders([("Content-Type", "application/x-www-form-urlencoded")])
        ) { request in
            let body = RefreshAccessTokenRequestBody(
                client_id: clientId,
                scope: "Files.Read Files.Read.All",
                refresh_token: refreshToken,
                grant_type: "refresh_token",
                client_secret: clientSecret
            )
            try request.content.encode(body, as: .urlEncodedForm)
        }
        return try response.content.decode(RefreshAccessTokenResponse.self)
    }
}

struct RefreshAccessTokenRequestBody: Codable {
    let client_id, scope, refresh_token, grant_type, client_secret: String
}

struct RefreshAccessTokenResponse: Content {
    let access_token, refresh_token, token_type, scope: String
    let expires_in: Int
}

struct GraphAPIClientKey: StorageKey {
    typealias Value = GraphAPIClient
}

extension Application {
    var graphAPIClient: GraphAPIClient! {
        get {
            self.storage[GraphAPIClientKey.self]
        }
        set {
            self.storage[GraphAPIClientKey.self] = newValue
        }
    }
}

struct GraphAPIKeys {
    let clientId: String
    let clientSecret: String
    let refreshToken: String
    let accessToken: String
}

struct GraphAPIKeysKey: StorageKey {
    typealias Value = GraphAPIKeys
}

extension Application {
    var graphAPIKeys: GraphAPIKeys! {
        get {
            self.storage[GraphAPIKeysKey.self]
        }
        set {
            self.storage[GraphAPIKeysKey.self] = newValue
        }
    }
}
