//
//  ApolloClient+Async.swift
//  repcount
//

import Apollo
import Foundation

enum ApolloAsyncError: LocalizedError {
    case missingData

    var errorDescription: String? {
        switch self {
        case .missingData:
            return "GraphQL response did not include data."
        }
    }
}

extension ApolloClient {
    func fetchAsync<Query: GraphQLQuery>(query: Query) async throws -> Query.Data {
        try await withCheckedThrowingContinuation { continuation in
            self.fetch(query: query) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        continuation.resume(returning: data)
                    } else if let error = graphQLResult.errors?.first {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: ApolloAsyncError.missingData)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func performAsync<Mutation: GraphQLMutation>(mutation: Mutation) async throws -> Mutation.Data {
        try await withCheckedThrowingContinuation { continuation in
            self.perform(mutation: mutation) { result in
                switch result {
                case .success(let graphQLResult):
                    if let data = graphQLResult.data {
                        continuation.resume(returning: data)
                    } else if let error = graphQLResult.errors?.first {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: ApolloAsyncError.missingData)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
