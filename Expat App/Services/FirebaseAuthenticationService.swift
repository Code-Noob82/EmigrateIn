//
//  FirebaseAuthenticationService.swift
//  Expat App
//

import FirebaseAuth
import Foundation
import GoogleSignIn
import UIKit

enum AuthenticationServiceError: LocalizedError {
    case googleSignInCancelled
    case missingGoogleToken
    case missingPresentingViewController
    case noAuthenticatedUser
    case passwordRequired
    case unsupportedProvider

    var errorDescription: String? {
        switch self {
        case .googleSignInCancelled:
            return "Die Google-Anmeldung wurde abgebrochen."
        case .missingGoogleToken:
            return "Google hat kein gültiges Anmelde-Token geliefert."
        case .missingPresentingViewController:
            return "Die Google-Anmeldung konnte nicht angezeigt werden."
        case .noAuthenticatedUser:
            return "Es ist kein Nutzer angemeldet."
        case .passwordRequired:
            return "Für die Bestätigung ist das aktuelle Passwort erforderlich."
        case .unsupportedProvider:
            return "Diese Anmeldemethode unterstützt die Kontolöschung noch nicht."
        }
    }
}

@MainActor
final class FirebaseAuthenticationService: AuthenticationServiceProtocol {
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    var currentSession: UserSession? {
        Self.makeSession(from: Auth.auth().currentUser)
    }

    func startAuthStateObservation(_ handler: @escaping (UserSession?) -> Void) {
        stopAuthStateObservation()
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            let session = Self.makeSession(from: user)
            Task { @MainActor in
                handler(session)
            }
        }
    }

    func stopAuthStateObservation() {
        guard let authStateHandle else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandle)
        self.authStateHandle = nil
    }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        if let user = Auth.auth().currentUser, user.isAnonymous {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            _ = try await user.link(with: credential)
        } else {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
        }
    }

    func signInAnonymously() async throws {
        _ = try await Auth.auth().signInAnonymously()
    }

    func signInWithGoogle() async throws {
        let credential = try await googleCredential()
        if let user = Auth.auth().currentUser, user.isAnonymous {
            _ = try await user.link(with: credential)
        } else {
            _ = try await Auth.auth().signIn(with: credential)
        }
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func updateDisplayName(_ displayName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationServiceError.noAuthenticatedUser
        }
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        try await request.commitChanges()
    }

    func reauthenticateForAccountDeletion(
        using method: AccountReauthenticationMethod,
        password: String?
    ) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationServiceError.noAuthenticatedUser
        }

        switch method {
        case .password:
            guard let email = user.email,
                  let password,
                  !password.isEmpty else {
                throw AuthenticationServiceError.passwordRequired
            }
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            _ = try await user.reauthenticate(with: credential)
        case .google:
            let credential = try await googleCredential()
            _ = try await user.reauthenticate(with: credential)
        case .none:
            return
        case .unsupported:
            throw AuthenticationServiceError.unsupportedProvider
        }
    }

    func deleteCurrentUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthenticationServiceError.noAuthenticatedUser
        }
        try await user.delete()
    }

    private func googleCredential() async throws -> AuthCredential {
        guard let presentingViewController = UIApplication.shared.keyWindowPresentedController else {
            throw AuthenticationServiceError.missingPresentingViewController
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            guard let token = result.user.idToken?.tokenString else {
                throw AuthenticationServiceError.missingGoogleToken
            }
            return GoogleAuthProvider.credential(
                withIDToken: token,
                accessToken: result.user.accessToken.tokenString
            )
        } catch let error as NSError
            where error.domain == kGIDSignInErrorDomain &&
            error.code == GIDSignInError.canceled.rawValue {
            throw AuthenticationServiceError.googleSignInCancelled
        }
    }

    private static func makeSession(from user: User?) -> UserSession? {
        guard let user else { return nil }

        let providerIDs = Set(user.providerData.map(\.providerID))
        let reauthenticationMethod: AccountReauthenticationMethod
        if user.isAnonymous {
            reauthenticationMethod = .none
        } else if providerIDs.contains(EmailAuthProviderID) {
            reauthenticationMethod = .password
        } else if providerIDs.contains(GoogleAuthProviderID) {
            reauthenticationMethod = .google
        } else {
            reauthenticationMethod = .unsupported
        }

        return UserSession(
            id: user.uid,
            email: user.email,
            isAnonymous: user.isAnonymous,
            reauthenticationMethod: reauthenticationMethod
        )
    }
}
