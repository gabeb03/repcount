//
//  PushupRepository.swift
//  repcount
//

import Foundation
import Apollo

enum AppConfiguration {
    static var endpointURL: URL {
        if let env = ProcessInfo.processInfo.environment["PUSHUP_GRAPHQL_ENDPOINT"],
           let url = URL(string: env) {
            return url
        }
        if let plistValue = Bundle.main.object(forInfoDictionaryKey: "PUSHUP_GRAPHQL_ENDPOINT") as? String,
           let url = URL(string: plistValue) {
            return url
        }
        return URL(string: "https://repcount.gadget.app/api/graphql")!
    }

    static var userID: String {
        if let env = ProcessInfo.processInfo.environment["PUSHUP_USER_ID"], !env.isEmpty {
            return env
        }
        if let plistValue = Bundle.main.object(forInfoDictionaryKey: "PUSHUP_USER_ID") as? String, !plistValue.isEmpty {
            return plistValue
        }
        // Fallback demo user. Update for production environments.
        return "demo-user"
    }
}

protocol PushupRepositoryProtocol {
    func fetchEntries(for userId: String) async throws -> [PushupEntry]
    func createEntry(for userId: String, count: Int) async throws -> PushupEntry
    func updateEntry(id: String, count: Int) async throws -> PushupEntry
    func deleteEntry(id: String) async throws
}

struct PushupRepositoryError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

final class PushupRepository: PushupRepositoryProtocol {
    private let sessionManager: AuthSessionManager

    init(sessionManager: AuthSessionManager = .shared) {
        self.sessionManager = sessionManager
    }

    private func client() -> ApolloClient {
        return APINetwork.shared.client(sessionToken: sessionManager.session?.token)
    }

    func fetchEntries(for userId: String) async throws -> [PushupEntry] {
        let query = RepcountAPI.GetUserPushupsQuery(userId: userId)
        let result = try await client().fetchAsync(query: query)
        let entries = result.pushups.edges.map { $0.node.toEntry() }
        return entries.sorted { $0.displayDate > $1.displayDate }
    }

    func createEntry(for userId: String, count: Int) async throws -> PushupEntry {
        var input = RepcountAPI.CreatePushupInput()
        input.numberOfPushups = .some(Double(count))
        var userInput = RepcountAPI.UserBelongsToInput()
        userInput._link = .some(userId)
        input.user = .some(userInput)
        let mutation = RepcountAPI.CreatePushupMutation(pushup: .some(input))
        let result = try await client().performAsync(mutation: mutation)
        guard let pushup = result.createPushup?.pushup else {
            throw PushupRepositoryError(message: result.createPushup?.errors?.first?.message ?? "Unable to create push-up.")
        }
        return pushup.toEntry()
    }

    func updateEntry(id: String, count: Int) async throws -> PushupEntry {
        var input = RepcountAPI.UpdatePushupInput()
        input.numberOfPushups = .some(Double(count))
        let mutation = RepcountAPI.UpdatePushupMutation(id: id, pushup: .some(input))
        let result = try await client().performAsync(mutation: mutation)
        guard let pushup = result.updatePushup?.pushup else {
            throw PushupRepositoryError(message: result.updatePushup?.errors?.first?.message ?? "Unable to update push-up.")
        }
        return pushup.toEntry()
    }

    func deleteEntry(id: String) async throws {
        let mutation = RepcountAPI.DeletePushupMutation(id: id)
        let result = try await client().performAsync(mutation: mutation)
        if result.deletePushup?.success == false {
            throw PushupRepositoryError(message: result.deletePushup?.errors?.first?.message ?? "Unable to delete push-up.")
        }
    }
}

// MARK: - Mapping Helpers

private let isoFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

private let fallbackISOFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
}()

private func parseISODate(_ value: String) -> Date {
    if let date = isoFormatter.date(from: value) {
        return date
    }
    return fallbackISOFormatter.date(from: value) ?? Date()
}

private extension RepcountAPI.GetUserPushupsQuery.Data.Pushups.Edge.Node {
    func toEntry() -> PushupEntry {
        let created = parseISODate(createdAt)
        let updated = parseISODate(updatedAt)
        return PushupEntry(id: id, count: Int(numberOfPushups), createdAt: created, updatedAt: updated, notes: nil)
    }
}

private extension RepcountAPI.CreatePushupMutation.Data.CreatePushup.Pushup {
    func toEntry() -> PushupEntry {
        let created = parseISODate(createdAt)
        let updated = parseISODate(updatedAt)
        return PushupEntry(id: id, count: Int(numberOfPushups), createdAt: created, updatedAt: updated, notes: nil)
    }
}

private extension RepcountAPI.UpdatePushupMutation.Data.UpdatePushup.Pushup {
    func toEntry() -> PushupEntry {
        let created = parseISODate(createdAt)
        let updated = parseISODate(updatedAt)
        return PushupEntry(id: id, count: Int(numberOfPushups), createdAt: created, updatedAt: updated, notes: nil)
    }
}

// MARK: - Mock repository for previews/offline flows

struct MockPushupRepository: PushupRepositoryProtocol {
    func fetchEntries(for userId: String) async throws -> [PushupEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<20).map { index in
            let date = calendar.date(byAdding: .day, value: -index, to: today) ?? today
            let count = Int.random(in: 20...80)
            return PushupEntry(id: UUID().uuidString, count: count, createdAt: date, updatedAt: date, notes: index % 3 == 0 ? "Felt strong 👍" : nil)
        }
    }

    func createEntry(for userId: String, count: Int) async throws -> PushupEntry {
        let now = Date()
        return PushupEntry(id: UUID().uuidString, count: count, createdAt: now, updatedAt: now)
    }

    func updateEntry(id: String, count: Int) async throws -> PushupEntry {
        let now = Date()
        return PushupEntry(id: id, count: count, createdAt: now, updatedAt: now)
    }

    func deleteEntry(id: String) async throws {}
}
