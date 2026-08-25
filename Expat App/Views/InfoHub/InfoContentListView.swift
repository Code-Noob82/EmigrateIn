//
//  InfoContentListView.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI
import MarkdownUI

struct InfoContentListView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @StateObject private var viewModel: InfoContentViewModel
    @State private var showRegistrationPrompt = false
    @State private var tappedContentItem: InfoContent?
    let category: InfoCategory
    let backgroundGradient = AppStyles.backgroundGradient
    // Wichtige Konstante: Die ID der Kategorie, welche die Bundesland-Details anzeigen soll
    let stateInfoCategoryID = "state_info_de"
    
    init(category: InfoCategory) {
        self.category = category
        _viewModel = StateObject(wrappedValue: InfoContentViewModel(categoryId: category.id ?? "Fehlende_ID"))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            // Nur eine der folgenden Ansichten soll angezeigt werden.
            if category.id == stateInfoCategoryID {
                StateDetailView()
                    .environmentObject(profileViewModel)
            } else if viewModel.isLoading {
                // Ansonsten, wenn es eine andere Kategorie ist und lädt...
                ProgressView()
                    .tint(AppStyles.primaryTextColor)
                
            } else if let errorMessage = viewModel.errorMessage {
                // Ansonsten, wenn es eine andere Kategorie ist und einen Fehler hat...
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppStyles.destructiveColor)
                        .padding(.bottom, 5)
                    
                    Text("Fehler")
                        .font(.headline)
                        .foregroundColor(AppStyles.primaryTextColor)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Erneut versuchen") {
                        Task { await viewModel.fetchContent() }
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                    .tint(AppStyles.buttonBackgroundColor)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if viewModel.contentItems.isEmpty {
                VStack {
                    Text("Keine Inhalte für diese Kategorie gefunden.")
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Ansonsten, wenn es eine andere Kategorie ist und Inhalte hat...
                ScrollView {
                    let columns = [
                        GridItem(.adaptive(minimum: 150, maximum: 240), spacing: 16)
                    ]
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.contentItems) { contentItem in
                            InfoContentGridItemView(
                                contentItem: contentItem,
                                showRegistrationPrompt: $showRegistrationPrompt,
                                tappedContentItem: $tappedContentItem
                            )
                            .environmentObject(authViewModel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(backgroundGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
        .task(id: authViewModel.session?.id) {
            if authViewModel.isAuthenticated,
               category.id != stateInfoCategoryID,
               viewModel.contentItems.isEmpty,
               viewModel.errorMessage == nil {
                await viewModel.fetchContent()
            }
        }
        // Alert für anonyme Nutzer
        .alert("Registrierung erforderlich", isPresented: $showRegistrationPrompt) {
            Button("Registrieren") {
                authViewModel.switchToRegistrationFromAnonymous()
            }
            .foregroundColor(AppStyles.primaryTextColor)
            Button("Abbrechen", role: .cancel) {
                
            }
            .foregroundColor(AppStyles.destructiveColor)
        } message: {
            Text("Registriere dein Gastkonto, um die vollständigen Details sehen zu können.")
        }
    }
}

#Preview("Info Content List") {
    let dummyCategory = InfoCategory(
        id: "state_info_de",
        title: "Ankunft & Erste Schritte",
        subtitle: "Behörden etc.",
        iconName: "figure.wave.circle.fill",
        order: 20
    )
    InfoContentListView(category: dummyCategory)
        .environmentObject(AuthenticationViewModel())
        .environmentObject(UserProfileViewModel())
}
