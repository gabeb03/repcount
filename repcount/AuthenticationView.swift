//
//  AuthenticationView.swift
//  repcount
//

import SwiftUI

struct AuthenticationView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Sign Up"

        var id: String { rawValue }
    }

    var onAuthenticated: (AuthSession) -> Void

    @State private var mode: Mode = .signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Repcount")
                    .font(.largeTitle.bold())
                Text(mode == .signIn ? "Welcome back! Let's keep that streak moving." : "Create an account to start logging your reps.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            Picker("", selection: $mode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemBackground)))

                SecureField("Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemBackground)))

                if mode == .signUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemBackground)))
                }
            }

            if let message = errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.red)
            }

            Button(action: submit) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text(mode == .signIn ? "Sign In" : "Create Account")
                        .font(.headline)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSubmitting || !isFormValid)

            Spacer()
        }
        .padding(30)
    }

    private var isFormValid: Bool {
        guard !email.isEmpty, !password.isEmpty else { return false }
        if mode == .signUp {
            return password == confirmPassword && password.count >= 6
        }
        return true
    }

    private func submit() {
        guard !isSubmitting else { return }
        errorMessage = nil
        isSubmitting = true
        Task {
            do {
                let session: AuthSession
                if mode == .signIn {
                    session = try await AuthService.shared.signIn(email: email, password: password)
                } else {
                    session = try await AuthService.shared.signUp(email: email, password: password)
                }
                await MainActor.run {
                    onAuthenticated(session)
                    email = ""
                    password = ""
                    confirmPassword = ""
                }
            } catch {
                await MainActor.run {
                    print("Gadget API error: ", error)
                    errorMessage = error.localizedDescription
                }
            }
            await MainActor.run {
                isSubmitting = false
            }
        }
    }
}

