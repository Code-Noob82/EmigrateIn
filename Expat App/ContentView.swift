//
//  ContentView.swift
//  Expat App
//
//  Created by Dominik Baki on 09.04.25.
//

import SwiftUI

// MARK: - ContentView (Verwaltet Auth vs. Haupt-App)

// Diese View entscheidet, ob der Login/Registrierungs-Screen oder die Haupt-App (Tabs) angezeigt wird.
struct ContentView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var userProfileViewModel: UserProfileViewModel

    var body: some View {
        Group {
            if authenticationViewModel.shouldShowMainApp {
                AppTabView()
                    .transition(.opacity.animation(.easeOut(duration: 0.5)))
            } else {
                AuthenticationView()
                    .transition(.opacity.animation(.easeOut(duration: 0.5)))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authenticationViewModel.shouldShowMainApp)
        .task {
            authenticationViewModel.startAuthStateObservation()
        }
        .task(id: authenticationViewModel.session) {
            await userProfileViewModel.handleSession(authenticationViewModel.session)
        }
        .sheet(isPresented: $userProfileViewModel.showStateSelection) {
            StateSelectionView()
        }
    }
}
