//
//  APINetwork.swift
//  repcount
//

import Apollo
import ApolloAPI
import Foundation

/// Primary networking layer for GraphQL.
/// Uses two ApolloClients: one for unauthenticated calls, and one with auth.
final class APINetwork {
    static let shared = APINetwork()

    private var authenticatedToken: String?
    private var authenticatedClient: ApolloClient
    private let unauthenticatedClient: ApolloClient

    private init() {
        self.unauthenticatedClient = APINetwork.makeClient(sessionToken: nil)

        let initialToken = AuthSessionManager.shared.session?.token
        self.authenticatedClient = APINetwork.makeClient(sessionToken: initialToken)
        self.authenticatedToken = initialToken
    }

    /// Returns the correct client depending on whether a session token exists.
    func client(sessionToken: String?) -> ApolloClient {
        guard let token = sessionToken, !token.isEmpty else {
            return unauthenticatedClient
        }

        // Recreate client if token has changed
        if token != authenticatedToken {
            authenticatedClient = APINetwork.makeClient(sessionToken: token)
            authenticatedToken = token
        }

        return authenticatedClient
    }

    // MARK: - Client Builder

    private static func makeClient(sessionToken: String?) -> ApolloClient {
        // Cache & normalized store
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)

        // Modern URLSession (ApolloURLSession)
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil

        let urlSession = URLSession(configuration: configuration)

        // Custom interceptor provider with authorization & token-capture logic
        let interceptorProvider = AuthInterceptorProvider(
            store: store,
            urlSession: urlSession,
            sessionManager: .shared // same singleton you already use
        )

        // The modern Apollo 2.x transport
        let transport = RequestChainNetworkTransport(
            urlSession: urlSession,
            interceptorProvider: interceptorProvider,
            store: store,
            endpointURL: AppConfiguration.endpointURL
        )

        return ApolloClient(networkTransport: transport, store: store)
    }
}
