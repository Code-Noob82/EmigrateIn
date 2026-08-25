import Foundation
import Testing
@testable import Expat_App

@MainActor
struct ViewModelTests {
    @Test
    func embassyDecoderIgnoresAdditionalCountryMetadata() throws {
        let json = """
        {
          "response": {
            "lastModified": 1,
            "country-group": {
              "lastModified": 2,
              "country": "Tschechien",
              "officialName": "Tschechische Republik",
              "representative": {
                "lastModified": 3,
                "description": "Botschaft der Bundesrepublik Deutschland",
                "city": "Prag",
                "country": "Tschechien"
              },
              "contentList": ["representative"]
            },
            "contentList": ["country-group"]
          }
        }
        """

        let result = try JSONDecoder().decode(EmbassyDataWrapper.self, from: Data(json.utf8))
        let countryGroup = try #require(result.response.countryGroups["country-group"])

        #expect(countryGroup.country == "Tschechien")
        #expect(countryGroup.representatives["representative"]?.city == "Prag")
    }

    @Test
    func registrationRejectsDifferentPasswords() async {
        let authenticationService = AuthenticationServiceMock()
        let viewModel = AuthenticationViewModel(authenticationService: authenticationService)
        viewModel.email = "familie@example.com"
        viewModel.password = "passwort1"
        viewModel.confirmPassword = "passwort2"

        await viewModel.signUpWithEmail()

        #expect(authenticationService.signUpCalls == 0)
        #expect(viewModel.activeError?.errorDescription == "Passwörter stimmen nicht überein.")
    }

    @Test
    func authStateObservationPublishesSession() {
        let authenticationService = AuthenticationServiceMock()
        authenticationService.currentSession = UserSession(
            id: "user-1",
            email: "familie@example.com",
            isAnonymous: false,
            reauthenticationMethod: .password
        )
        let viewModel = AuthenticationViewModel(authenticationService: authenticationService)

        viewModel.startAuthStateObservation()

        #expect(viewModel.isAuthenticated)
        #expect(!viewModel.isAnonymousUser)
        #expect(viewModel.email == "familie@example.com")
    }

    @Test
    func anonymousRegistrationKeepsUserIDWithoutSignOut() async {
        let authenticationService = AuthenticationServiceMock()
        authenticationService.currentSession = UserSession(
            id: "anonymous-user",
            email: nil,
            isAnonymous: true,
            reauthenticationMethod: .none
        )
        let viewModel = AuthenticationViewModel(authenticationService: authenticationService)
        viewModel.startAuthStateObservation()

        viewModel.switchToRegistrationFromAnonymous()

        #expect(viewModel.isUpgradingAnonymousUser)
        #expect(!viewModel.shouldShowMainApp)
        #expect(authenticationService.signOutCalls == 0)

        viewModel.email = "familie@example.com"
        viewModel.password = "geheim"
        viewModel.confirmPassword = "geheim"
        await viewModel.signUpWithEmail()

        #expect(authenticationService.currentSession?.id == "anonymous-user")
        #expect(viewModel.session?.id == "anonymous-user")
        #expect(viewModel.session?.isAnonymous == false)
        #expect(!viewModel.isUpgradingAnonymousUser)
        #expect(viewModel.shouldShowMainApp)
        #expect(authenticationService.signOutCalls == 0)
    }

    @Test
    func cancellingAnonymousRegistrationReturnsToGuestSession() {
        let authenticationService = AuthenticationServiceMock()
        authenticationService.currentSession = UserSession(
            id: "anonymous-user",
            email: nil,
            isAnonymous: true,
            reauthenticationMethod: .none
        )
        let viewModel = AuthenticationViewModel(authenticationService: authenticationService)
        viewModel.startAuthStateObservation()

        viewModel.switchToRegistrationFromAnonymous()
        viewModel.cancelAnonymousUpgrade()

        #expect(viewModel.session?.id == "anonymous-user")
        #expect(viewModel.isAnonymousUser)
        #expect(!viewModel.isUpgradingAnonymousUser)
        #expect(viewModel.shouldShowMainApp)
        #expect(authenticationService.signOutCalls == 0)
    }

    @Test
    func missingProfileIsCreatedAndRequestsStateSelection() async {
        let authenticationService = AuthenticationServiceMock()
        let session = UserSession(
            id: "user-2",
            email: "familie@example.com",
            isAnonymous: false,
            reauthenticationMethod: .password
        )
        authenticationService.currentSession = session
        let repository = UserProfileRepositoryMock()
        let viewModel = UserProfileViewModel(
            repository: repository,
            authenticationService: authenticationService
        )

        await viewModel.handleSession(session)

        #expect(repository.createdProfiles == ["user-2"])
        #expect(viewModel.showStateSelection)
    }

    @Test
    func accountDeletionReauthenticatesAndDeletesUserData() async {
        let authenticationService = AuthenticationServiceMock()
        authenticationService.currentSession = UserSession(
            id: "user-3",
            email: "familie@example.com",
            isAnonymous: false,
            reauthenticationMethod: .password
        )
        let repository = UserProfileRepositoryMock()
        let viewModel = AccountDeletionViewModel(
            authenticationService: authenticationService,
            profileRepository: repository
        )

        viewModel.prepareDeletion()
        viewModel.password = "geheim"
        await viewModel.deleteAccount()

        #expect(authenticationService.reauthenticationMethod == .password)
        #expect(authenticationService.reauthenticationPassword == "geheim")
        #expect(repository.deletedUserIDs == ["user-3"])
        #expect(authenticationService.didDeleteCurrentUser)
    }

    @Test
    func guestAccountDeletionRemovesDataAndAnonymousAuthUser() async {
        let authenticationService = AuthenticationServiceMock()
        authenticationService.currentSession = UserSession(
            id: "anonymous-user",
            email: nil,
            isAnonymous: true,
            reauthenticationMethod: .none
        )
        let repository = UserProfileRepositoryMock()
        let viewModel = AccountDeletionViewModel(
            authenticationService: authenticationService,
            profileRepository: repository
        )

        viewModel.prepareDeletion()
        await viewModel.deleteAccount()

        #expect(authenticationService.reauthenticationMethod == AccountReauthenticationMethod.none)
        #expect(repository.deletedUserIDs == ["anonymous-user"])
        #expect(authenticationService.didDeleteCurrentUser)
    }

    @Test
    func accountIsKeptWhenUserDataDeletionFails() async {
        let authenticationService = AuthenticationServiceMock()
        authenticationService.currentSession = UserSession(
            id: "user-4",
            email: "familie@example.com",
            isAnonymous: false,
            reauthenticationMethod: .password
        )
        let repository = UserProfileRepositoryMock()
        repository.deletionError = RepositoryMockError.deletionFailed
        let viewModel = AccountDeletionViewModel(
            authenticationService: authenticationService,
            profileRepository: repository
        )

        viewModel.prepareDeletion()
        viewModel.password = "geheim"
        await viewModel.deleteAccount()

        #expect(repository.deletedUserIDs == ["user-4"])
        #expect(!authenticationService.didDeleteCurrentUser)
        #expect(viewModel.errorMessage != nil)
    }
}

private enum RepositoryMockError: Error {
    case deletionFailed
}

@MainActor
private final class AuthenticationServiceMock: AuthenticationServiceProtocol {
    var currentSession: UserSession?
    var signUpCalls = 0
    var signOutCalls = 0
    var reauthenticationMethod: AccountReauthenticationMethod?
    var reauthenticationPassword: String?
    var didDeleteCurrentUser = false
    private var stateHandler: ((UserSession?) -> Void)?

    func startAuthStateObservation(_ handler: @escaping (UserSession?) -> Void) {
        stateHandler = handler
        handler(currentSession)
    }

    func stopAuthStateObservation() {
        stateHandler = nil
    }

    func signIn(email: String, password: String) async throws {}

    func signUp(email: String, password: String) async throws {
        signUpCalls += 1
        if let currentSession, currentSession.isAnonymous {
            let registeredSession = UserSession(
                id: currentSession.id,
                email: email,
                isAnonymous: false,
                reauthenticationMethod: .password
            )
            self.currentSession = registeredSession
            stateHandler?(registeredSession)
        }
    }

    func signInAnonymously() async throws {}
    func signInWithGoogle() async throws {}
    func sendPasswordReset(email: String) async throws {}
    func signOut() throws {
        signOutCalls += 1
        currentSession = nil
        stateHandler?(nil)
    }
    func updateDisplayName(_ displayName: String) async throws {}

    func reauthenticateForAccountDeletion(
        using method: AccountReauthenticationMethod,
        password: String?
    ) async throws {
        reauthenticationMethod = method
        reauthenticationPassword = password
    }

    func deleteCurrentUser() async throws {
        didDeleteCurrentUser = true
    }
}

private final class UserProfileRepositoryMock: UserProfileRepositoryProtocol {
    var profile: UserProfile?
    var createdProfiles: [String] = []
    var deletedUserIDs: [String] = []
    var deletionError: Error?

    func fetchGermanStates() async throws -> [StateSpecificInfo] { [] }
    func fetchProfile(userID: String) async throws -> UserProfile? { profile }

    func createInitialProfile(userID: String, email: String) async throws {
        createdProfiles.append(userID)
    }

    func updateHomeState(userID: String, stateID: String) async throws {}
    func updateDisplayName(userID: String, displayName: String) async throws {}
    func fetchStateDetails(stateID: String) async throws -> StateSpecificInfo? { nil }

    func deleteAllUserData(userID: String) async throws {
        deletedUserIDs.append(userID)
        if let deletionError {
            throw deletionError
        }
    }
}
