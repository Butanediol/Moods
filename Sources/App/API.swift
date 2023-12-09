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
    
    func refreshAccessToken(clientId: String, refreshToken: String, clientSecret: String) async throws -> String {
        let uri = URI(string: "https://login.microsoftonline.com/common/oauth2/v2.0/token&client_id=\(clientId)&scope=files.read%20files.read.all&refresh_token=\(refreshToken)&grant_type=refresh_token&client_secret=\(clientSecret)")
        client.post(uri)
    }
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
