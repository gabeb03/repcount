//
//  AuthService.swift
//  repcount
//

import Foundation

enum AuthServiceError: LocalizedError {
    case invalidCredentials
    case missingSession
    case signupFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Unable to sign in with those credentials."
        case .missingSession:
            return "The server did not return a session token."
        case .signupFailed(let message):
            return message
        }
    }
}

final class AuthService {
    static let shared = AuthService()

    private let sessionManager = AuthSessionManager.shared

    var currentSession: AuthSession? {
        sessionManager.session
    }

    func restoreSession() -> AuthSession? {
        sessionManager.session
    }

    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthSession {
        let client = APINetwork.shared.client(sessionToken: nil)
        let mutation = RepcountAPI.SignInMutation(email: email, password: password)
        let data = try await client.performAsync(mutation: mutation)
        guard let result = data.signInUser, result.success, let user = result.user else {
            throw AuthServiceError.invalidCredentials
        }
        guard let payload = parse(jsonString: user._all),
              let userId = payload["id"] as? String,
              let emailValue = payload["email"] as? String ?? payload["Email"] as? String,
              let token = extractToken(from: payload) else {
            throw AuthServiceError.missingSession
        }
        let session = AuthSession(token: token, userId: userId, email: emailValue)
        sessionManager.update(session: session)
        return session
    }

    @discardableResult
    func signUp(email: String, password: String) async throws -> AuthSession {
        let client = APINetwork.shared.client(sessionToken: nil)
        let mutation = RepcountAPI.SignUpMutation(email: email, password: password)
        let data = try await client.performAsync(mutation: mutation)
        guard let result = data.signUpUser else {
            throw AuthServiceError.signupFailed("Missing response from server.")
        }
        if result.success {
            return try await signIn(email: email, password: password)
        } else if let error = result.errors?.first {
            throw AuthServiceError.signupFailed(error.message)
        } else {
            throw AuthServiceError.signupFailed("Unable to create account.")
        }
    }

    func signOut() {
        sessionManager.update(session: nil)
    }

    private func parse(jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }

    private func extractToken(from dictionary: [String: Any]) -> String? {
        if let token = dictionary["sessionToken"] as? String {
            return token
        }
        if let token = dictionary["session_token"] as? String {
            return token
        }
        if let session = dictionary["session"] as? [String: Any],
           let token = session["token"] as? String {
            return token
        }
        return nil
    }
}

