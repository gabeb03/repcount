//
//  AuthSessionManager.swift
//  repcount
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    func save(_ data: Data, forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func getData(_ key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }

    func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]

        SecItemDelete(query as CFDictionary)
    }
}

struct AuthSession: Codable, Equatable {
    let token: String
    let userId: String
    let email: String
}

final class AuthSessionManager {
    static let shared = AuthSessionManager()

    private let key = "com.repcount.session"
    private let keychain = KeychainManager.shared
    private(set) var session: AuthSession?

    private init() {
        if let data = keychain.getData(key),
           let decoded = try? JSONDecoder().decode(AuthSession.self, from: data) {
            session = decoded
        }
    }

    func update(session: AuthSession?) {
        self.session = session
        if let session,
           let data = try? JSONEncoder().encode(session) {
            keychain.save(data, forKey: key)
        } else {
            keychain.delete(key)
        }
    }

    func updateToken(_ token: String) {
        guard !token.isEmpty else { return }
        if var current = session {
            current = AuthSession(token: token, userId: current.userId, email: current.email)
            update(session: current)
        } else {
            let session = AuthSession(token: token, userId: "", email: "")
            update(session: session)
        }
    }
}

