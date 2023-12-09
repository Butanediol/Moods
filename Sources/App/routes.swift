import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async throws -> [DriveItem] in
        guard let accessToken = try await AccessToken.query(on: req.db).first() else {
            throw Abort(.custom(code: 404, reasonPhrase: "Access token not found."))
        }
        return try await req.application.graphAPIClient.listItems(paths: ["Sync", "Rime"], token: accessToken)
    }

    try app.register(collection: TodoController())
}
