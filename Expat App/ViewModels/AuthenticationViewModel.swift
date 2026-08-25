//
//  AuthenticationViewModel.swift
//  Expat App
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var currentAuthView: AuthViewType = .login
    @Published private(set) var session: UserSession?
    @Published private(set) var isLoading = false
    @Published private(set) var isUpgradingAnonymousUser = false
    @Published var activeError: AppError?
    @Published var successMessage: String?

    private let authenticationService: AuthenticationServiceProtocol
    private var isObservingAuthState = false

    var isAuthenticated: Bool { session != nil }
    var isAnonymousUser: Bool { session?.isAnonymous == true }
    var shouldShowMainApp: Bool { isAuthenticated && !isUpgradingAnonymousUser }

    init(authenticationService: AuthenticationServiceProtocol) {
        self.authenticationService = authenticationService
    }

    convenience init() {
        self.init(authenticationService: FirebaseAuthenticationService())
    }

    func startAuthStateObservation() {
        guard !isObservingAuthState else { return }
        isObservingAuthState = true
        authenticationService.startAuthStateObservation { [weak self] session in
            guard let self else { return }
            self.session = session
            self.isLoading = false
            self.activeError = nil

            if let session {
                if !session.isAnonymous {
                    self.isUpgradingAnonymousUser = false
                }
                self.email = session.email ?? ""
                self.password = ""
                self.confirmPassword = ""
            } else {
                self.isUpgradingAnonymousUser = false
                self.email = ""
                self.password = ""
                self.confirmPassword = ""
                self.currentAuthView = .login
            }
        }
    }

    func signInWithEmail() async {
        await performAuthentication(
            error: { .generalLoginFailed(originalError: $0) },
            operation: { try await authenticationService.signIn(email: email, password: password) }
        )
    }

    func signUpWithEmail() async {
        guard password == confirmPassword else {
            activeError = .generalError(message: "Passwörter stimmen nicht überein.")
            return
        }
        let succeeded = await performAuthentication(
            error: { .generalSignUpFailed(originalError: $0) },
            operation: { try await authenticationService.signUp(email: email, password: password) }
        )
        if succeeded {
            completeAnonymousUpgradeIfNeeded()
        }
    }

    func signInAnonymously() async {
        await performAuthentication(
            error: { .anonymousSignInFailed(originalError: $0) },
            operation: { try await authenticationService.signInAnonymously() }
        )
    }

    func signInWithGoogle() async {
        isLoading = true
        activeError = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            try await authenticationService.signInWithGoogle()
            completeAnonymousUpgradeIfNeeded()
        } catch AuthenticationServiceError.googleSignInCancelled {
            return
        } catch {
            activeError = .googleSignInFailed(originalError: error)
        }
    }

    func forgotPassword() async {
        isLoading = true
        activeError = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            try await authenticationService.sendPasswordReset(email: email)
            successMessage = "Eine E-Mail zum Zurücksetzen des Passworts wurde an \(email) gesendet."
        } catch {
            activeError = .passwordResetFailed(originalError: error)
        }
    }

    func signOut() {
        activeError = nil
        successMessage = nil
        do {
            try authenticationService.signOut()
        } catch {
            activeError = .signOutFailed(originalError: error)
        }
    }

    func switchToRegistrationFromAnonymous() {
        guard isAnonymousUser else { return }
        email = ""
        password = ""
        confirmPassword = ""
        activeError = nil
        successMessage = nil
        currentAuthView = .registration
        isUpgradingAnonymousUser = true
    }

    func cancelAnonymousUpgrade() {
        guard isUpgradingAnonymousUser else { return }
        isUpgradingAnonymousUser = false
        email = ""
        password = ""
        confirmPassword = ""
        activeError = nil
        currentAuthView = .login
    }

    @discardableResult
    private func performAuthentication(
        error errorMapper: (Error) -> AppError,
        operation: () async throws -> Void
    ) async -> Bool {
        isLoading = true
        activeError = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            try await operation()
            return true
        } catch {
            activeError = errorMapper(error)
            return false
        }
    }

    private func completeAnonymousUpgradeIfNeeded() {
        guard isUpgradingAnonymousUser,
              let currentSession = authenticationService.currentSession,
              !currentSession.isAnonymous else { return }
        session = currentSession
        isUpgradingAnonymousUser = false
    }
}
