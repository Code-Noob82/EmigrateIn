//
//  AuthenticationServiceProtocol.swift
//  Expat App
//

import Foundation

enum AccountReauthenticationMethod: Equatable, Sendable {
    case password
    case google
    case none
    case unsupported
}

struct UserSession: Equatable, Hashable, Sendable {
    let id: String
    let email: String?
    let isAnonymous: Bool
    let reauthenticationMethod: AccountReauthenticationMethod
}

@MainActor
protocol AuthenticationServiceProtocol: AnyObject {
    var currentSession: UserSession? { get }

    func startAuthStateObservation(_ handler: @escaping (UserSession?) -> Void)
    func stopAuthStateObservation()
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signInAnonymously() async throws
    func signInWithGoogle() async throws
    func sendPasswordReset(email: String) async throws
    func signOut() throws
    func updateDisplayName(_ displayName: String) async throws
    func reauthenticateForAccountDeletion(
        using method: AccountReauthenticationMethod,
        password: String?
    ) async throws
    func deleteCurrentUser() async throws
}
