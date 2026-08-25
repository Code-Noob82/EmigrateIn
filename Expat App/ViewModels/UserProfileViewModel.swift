//
//  UserProfileViewModel.swift
//  Expat App
//

import Foundation

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var germanStates: [StateSpecificInfo] = []
    @Published private(set) var selectedStateDetails: StateSpecificInfo?
    @Published var selectedStateID: String?
    @Published var showStateSelection = false
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingStateDetails = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let repository: UserProfileRepositoryProtocol
    private let authenticationService: AuthenticationServiceProtocol
    private var currentUserID: String?

    var homeStateName: String? {
        guard let stateID = userProfile?.homeStateId, !stateID.isEmpty else { return nil }
        return germanStates.first { $0.id == stateID }?.stateName
    }

    init(
        repository: UserProfileRepositoryProtocol,
        authenticationService: AuthenticationServiceProtocol
    ) {
        self.repository = repository
        self.authenticationService = authenticationService
    }

    convenience init() {
        self.init(
            repository: UserProfileRepository(),
            authenticationService: FirebaseAuthenticationService()
        )
    }

    func handleSession(_ session: UserSession?) async {
        guard let session, !session.isAnonymous else {
            reset()
            return
        }

        guard currentUserID != session.id || userProfile == nil else { return }
        currentUserID = session.id
        await loadProfile(userID: session.id, email: session.email ?? "")
    }

    func reloadProfile() async {
        guard let session = authenticationService.currentSession, !session.isAnonymous else {
            reset()
            return
        }
        await loadProfile(userID: session.id, email: session.email ?? "")
    }

    func saveSelectedState() async {
        guard let userID = currentUserID else {
            errorMessage = "Nutzer nicht angemeldet."
            return
        }
        guard let selectedStateID else {
            errorMessage = "Bitte wähle ein Bundesland aus."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await repository.updateHomeState(userID: userID, stateID: selectedStateID)
            userProfile = try await repository.fetchProfile(userID: userID)
            showStateSelection = false
            await fetchSelectedStateDetails()
        } catch {
            errorMessage = "Das Bundesland konnte nicht gespeichert werden: \(error.localizedDescription)"
            showStateSelection = true
        }
    }

    func updateDisplayName(_ newName: String) async {
        guard let userID = currentUserID else {
            errorMessage = "Nutzer nicht angemeldet."
            return
        }

        let displayName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !displayName.isEmpty else {
            errorMessage = "Anzeigename darf nicht leer sein."
            return
        }
        guard displayName != userProfile?.displayName else {
            successMessage = "Anzeigename ist bereits aktuell."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }

        do {
            try await authenticationService.updateDisplayName(displayName)
            try await repository.updateDisplayName(userID: userID, displayName: displayName)
            userProfile = try await repository.fetchProfile(userID: userID)
            successMessage = "Anzeigename erfolgreich aktualisiert."
        } catch {
            errorMessage = "Der Anzeigename konnte nicht geändert werden: \(error.localizedDescription)"
        }
    }

    func fetchSelectedStateDetails() async {
        guard let stateID = userProfile?.homeStateId, !stateID.isEmpty else {
            selectedStateDetails = nil
            return
        }

        isLoadingStateDetails = true
        errorMessage = nil
        defer { isLoadingStateDetails = false }

        do {
            selectedStateDetails = try await repository.fetchStateDetails(stateID: stateID)
            if selectedStateDetails == nil {
                errorMessage = "Details für das ausgewählte Bundesland wurden nicht gefunden."
            }
        } catch {
            selectedStateDetails = nil
            errorMessage = "Bundesland-Details konnten nicht geladen werden: \(error.localizedDescription)"
        }
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    private func loadProfile(userID: String, email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            germanStates = try await repository.fetchGermanStates()

            var profile = try await repository.fetchProfile(userID: userID)
            if profile == nil {
                try await repository.createInitialProfile(userID: userID, email: email)
                profile = try await repository.fetchProfile(userID: userID)
            }

            userProfile = profile
            selectedStateID = profile?.homeStateId
            showStateSelection = profile?.homeStateId?.isEmpty != false

            if showStateSelection {
                selectedStateDetails = nil
            } else {
                await fetchSelectedStateDetails()
            }
        } catch {
            userProfile = nil
            errorMessage = "Das Nutzerprofil konnte nicht geladen werden: \(error.localizedDescription)"
        }
    }

    private func reset() {
        currentUserID = nil
        userProfile = nil
        germanStates = []
        selectedStateDetails = nil
        selectedStateID = nil
        showStateSelection = false
        isLoading = false
        isLoadingStateDetails = false
        errorMessage = nil
        successMessage = nil
    }
}
