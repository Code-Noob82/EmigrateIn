//
//  Expat_AppApp.swift
//  Expat App
//
//  Created by Dominik Baki on 09.04.25.
//

import SwiftUI
import GoogleSignIn

@main
struct EmigrateInApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var userProfileViewModel: UserProfileViewModel
    @StateObject private var accountDeletionViewModel: AccountDeletionViewModel
    
    // Speichert, ob der Nutzer das Onboarding bereits abgeschlossen hat.
    // @AppStorage speichert diesen Wert persistent auf dem Gerät (in UserDefaults).
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    // State für die Anzeige des Splash Screens
    @State private var showingSplashScreen: Bool
    
    let backgroundGradient = AppStyles.backgroundGradient
    
    let splashScreenFullText: String = "EmigrateIn - Dein Zuhause im Ausland startet hier!"
    
    init() {
        let launchArguments = ProcessInfo.processInfo.arguments
#if DEBUG
        if launchArguments.contains("-resetOnboarding") {
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        }
#endif
        _showingSplashScreen = State(initialValue: !launchArguments.contains("-skipSplash"))

        let authenticationService = FirebaseAuthenticationService()
        let profileRepository = UserProfileRepository()
        _authenticationViewModel = StateObject(
            wrappedValue: AuthenticationViewModel(authenticationService: authenticationService)
        )
        _userProfileViewModel = StateObject(
            wrappedValue: UserProfileViewModel(
                repository: profileRepository,
                authenticationService: authenticationService
            )
        )
        _accountDeletionViewModel = StateObject(
            wrappedValue: AccountDeletionViewModel(
                authenticationService: authenticationService,
                profileRepository: profileRepository
            )
        )
    }
    
    var body: some Scene {
        WindowGroup {
            // --- Haupt-View-Logik ---
            ZStack {
                AppStyles.backgroundGradient.ignoresSafeArea()
                
                // Zeigt die passende Ansicht basierend auf dem Zustand
                if showingSplashScreen {
                    SplashScreenView()
                        .onAppear {
                            let logoAnimationTotalDuration = 0.5 + 1.5
                            let textAnimationDuration = 1.0 + (Double(splashScreenFullText.count) * 0.05)
                            let totalSplashScreenAnimationTime = max(logoAnimationTotalDuration, textAnimationDuration)
                            let finalDelayBeforeTransition = totalSplashScreenAnimationTime + 0.5
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + finalDelayBeforeTransition) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showingSplashScreen = false
                                }
                            }
                        }
                } else if !hasCompletedOnboarding {
                    // Zeige das Onboarding, wenn es noch nicht abgeschlossen wurde
                    OnboardingContainerView {
                        // Diese Aktion wird ausgeführt, wenn der "Los geht's!" Button gedrückt wird
                        withAnimation(.easeOut(duration: 0.7)) {
                            hasCompletedOnboarding = true // Markiert Onboarding als abgeschlossen
                        }
                    }
                    .transition(.move(edge: .trailing))
                } else {
                    // Nach Splash & Onboarding: Zeige die ContentView, die den Auth-Status prüft
                    ContentView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .opacity)
                        )
                        .environmentObject(authenticationViewModel)
                        .environmentObject(userProfileViewModel)
                        .environmentObject(accountDeletionViewModel)
                }
            }
            .onOpenURL { incomingURL in
                // Diese Funktion wird aufgerufen, wenn die App über ein URL Scheme geöffnet wird.
                GIDSignIn.sharedInstance.handle(incomingURL)
            }
            .animation(.default, value: showingSplashScreen)
            .animation(.default, value: hasCompletedOnboarding)
        }
    }
}
