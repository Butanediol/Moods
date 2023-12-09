import NIOSSL
import Fluent
import FluentPostgresDriver
import QueuesFluentDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    app.queues.use(.fluent())        
    app.queues.schedule(RefreshAccessTokenJob())
        .hourly()
        .at(0)

    app.migrations.add(JobMetadataMigrate())
    app.migrations.add(M0001CreateTokens())

    app.views.use(.leaf)

    guard let clientId = Environment.get("CLIENT_ID"),
          let clientSecret = Environment.get("CLIENT_SECRET"),
          let refreshToken = Environment.get("REFRESH_TOKEN"),
          let accessToken = Environment.get("ACCESS_TOKEN") else {
        throw MoodsError.runtimeError("Invalid Graph API value")
    }
    app.graphAPIKeys = GraphAPIKeys(
        clientId: clientId,
        clientSecret: clientSecret,
        refreshToken: refreshToken,
        accessToken: accessToken
    )
    app.graphAPIClient = GraphAPIClient(client: app.client)

    // register routes
    try routes(app)
}

enum MoodsError: Error {
    case runtimeError(String)
}
