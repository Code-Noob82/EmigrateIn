//
//  AccountDeletionViewModel.swift
//  Expat App
//

import Foundation

@MainActor
final class AccountDeletionViewModel: ObservableObject {
    @Published var showConfirmation = false
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let authenticationService: AuthenticationServiceProtocol
    private let profileRepository: UserProfileRepositoryProtocol
    private var reauthenticationMethod: AccountReauthenticationMethod = .unsupported

    var requiresPassword: Bool {
        reauthenticationMethod == .password
    }

    var confirmationMessage: String {
        switch reauthenticationMethod {
        case .password:
            return "Gib dein aktuelles Passwort ein. Anschließend werden dein Konto und deine gespeicherten Daten gelöscht."
        case .google:
            return "Zur Bestätigung wirst du erneut bei Google angemeldet. Anschließend werden dein Konto und deine gespeicherten Daten gelöscht."
        case .none:
            return "Dein Gastkonto und seine gespeicherten Daten werden dauerhaft gelöscht."
        case .unsupported:
            return "Diese Anmeldemethode kann derzeit nicht erneut bestätigt werden."
        }
    }

    init(
        authenticationService: AuthenticationServiceProtocol,
        profileRepository: UserProfileRepositoryProtocol
    ) {
        self.authenticationService = authenticationService
        self.profileRepository = profileRepository
    }

    convenience init() {
        self.init(
            authenticationService: FirebaseAuthenticationService(),
            profileRepository: UserProfileRepository()
        )
    }

    func prepareDeletion() {
        guard let session = authenticationService.currentSession else {
            errorMessage = "Es ist kein Nutzer angemeldet."
            return
        }
        password = ""
        errorMessage = nil
        successMessage = nil
        reauthenticationMethod = session.reauthenticationMethod
        showConfirmation = true
    }

    func deleteAccount() async {
        guard let session = authenticationService.currentSession else {
            errorMessage = "Es ist kein Nutzer angemeldet."
            return
        }
        guard reauthenticationMethod != .unsupported else {
            errorMessage = AuthenticationServiceError.unsupportedProvider.localizedDescription
            showConfirmation = false
            return
        }

        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
            password = ""
        }

        do {
            try await authenticationService.reauthenticateForAccountDeletion(
                using: reauthenticationMethod,
                password: password
            )
            try await profileRepository.deleteAllUserData(userID: session.id)
            try await authenticationService.deleteCurrentUser()
            successMessage = "Dein Konto wurde vollständig gelöscht."
            showConfirmation = false
        } catch {
            errorMessage = "Das Konto konnte nicht gelöscht werden: \(error.localizedDescription)"
        }
    }

    func cancelDeletion() {
        showConfirmation = false
        password = ""
        errorMessage = nil
    }
}
