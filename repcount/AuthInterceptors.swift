//
//  AuthInterceptors.swift
//  repcount
//

import Apollo
import ApolloAPI
import Foundation

// MARK: - Authorization Interceptor

struct AuthorizationInterceptor: HTTPInterceptor, Sendable {
    let sessionManager: AuthSessionManager

    init(sessionManager: AuthSessionManager = .shared) {
        self.sessionManager = sessionManager
    }

    func intercept(
        request: URLRequest,
        next: NextHTTPInterceptorFunction
    ) async throws -> HTTPResponse {
        var modified = request

        if let token = sessionManager.session?.token, !token.isEmpty {
            modified.setValue(token, forHTTPHeaderField: "Authorization")
        }

        return try await next(modified)
    }
}



// MARK: - Session Capture Interceptor

struct SessionCaptureInterceptor: HTTPInterceptor, Sendable {
    let sessionManager: AuthSessionManager
    private let headerName = "x-set-authorization"

    init(sessionManager: AuthSessionManager = .shared) {
        self.sessionManager = sessionManager
    }

    func intercept(
        request: URLRequest,
        next: NextHTTPInterceptorFunction
    ) async throws -> HTTPResponse {
        let response = try await next(request)

        if let value = extractToken(from: response.response), !value.isEmpty {
            sessionManager.updateToken(value)
        }

        return response
    }

    private func extractToken(from response: HTTPURLResponse) -> String? {
        // Direct match
        if let value = response.value(forHTTPHeaderField: headerName) {
            return value
        }

        // Case-insensitive fallback
        let target = headerName.lowercased()

        for (key, value) in response.allHeaderFields {
            if let keyStr = key as? String,
               keyStr.lowercased() == target,
               let stringValue = value as? String {
                return stringValue
            }
        }

        return nil
    }
}



// MARK: - Interceptor Provider (Apollo 2.x)

struct AuthInterceptorProvider: InterceptorProvider {
    private let store: ApolloStore
    private let urlSession: ApolloURLSession
    private let sessionManager: AuthSessionManager

    init(
        store: ApolloStore,
        urlSession: ApolloURLSession,
        sessionManager: AuthSessionManager = .shared
    ) {
        self.store = store
        self.urlSession = urlSession
        self.sessionManager = sessionManager
    }

    // GraphQL interceptors (unchanged)
    func graphQLInterceptors<Operation>(
        for operation: Operation
    ) -> [GraphQLInterceptor] where Operation: GraphQLOperation {
        DefaultInterceptorProvider.shared.graphQLInterceptors(for: operation)
    }

    func cacheInterceptor<Operation>(
        for operation: Operation
    ) -> CacheInterceptor where Operation: GraphQLOperation {
        DefaultInterceptorProvider.shared.cacheInterceptor(for: operation)
    }

    // HTTP interceptors (this is where auth goes)
    func httpInterceptors<Operation>(
        for operation: Operation
    ) -> [HTTPInterceptor] where Operation: GraphQLOperation {

        var interceptors: [HTTPInterceptor] = [
            AuthorizationInterceptor(sessionManager: sessionManager),
            SessionCaptureInterceptor(sessionManager: sessionManager)
        ]

        interceptors.append(contentsOf: DefaultInterceptorProvider.shared.httpInterceptors(for: operation))
        return interceptors
    }

    func responseParser<Operation>(
        for operation: Operation
    ) -> ResponseParsingInterceptor where Operation: GraphQLOperation {
        DefaultInterceptorProvider.shared.responseParser(for: operation)
    }
}
