//
//  StateDetailView.swift
//  Expat App
//
//  Created by Dominik Baki on 16.05.25.
//

import SwiftUI
import FirebaseFirestore
import MarkdownUI

struct StateDetailView: View {
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    if profileViewModel.isLoadingStateDetails {
                        ProgressView("Lade Bundesland-Details...")
                            .padding()
                            .tint(AppStyles.primaryTextColor)
                        
                    } else if let details = profileViewModel.selectedStateDetails {
                        // Haupttitel des Bundeslandes
                        Text(details.stateName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppStyles.primaryTextColor)
                            .padding(.bottom)
                        
                        // MARK: - Apostille Informationen
                        if let apostilleInfoText = details.apostilleInfo, !apostilleInfoText.isEmpty {
                            SectionView(title: "Apostille Informationen", content: apostilleInfoText)
                                .foregroundColor(AppStyles.secondaryTextColor)
                        }
                        
                        // MARK: - Zuständige Behörden für Apostillen
                        if let authorities = details.apostilleAuthorities, !authorities.isEmpty {
                            Text("Zuständige Behörden für Apostillen:")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(AppStyles.primaryTextColor)
                                .padding(.top)
                                .padding(.bottom, 5)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(authorities) { authority in
                                    VStack(alignment: .leading) {
                                        Text(authority.name)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppStyles.primaryTextColor)
                                        
                                        // Zeigt den Link als klickbaren Link an, wenn er gültig ist
                                        if let linkString = authority.link, let url = URL(string: linkString) {
                                            Link(destination: url) {
                                                HStack(spacing: 5) {
                                                    Image(systemName: "safari.fill")
                                                        .font(.caption)
                                                        .foregroundColor(Color.blue)
                                                    
                                                    Text(authority.name + " Webseite")
                                                        .font(.caption)
                                                        .lineLimit(1)
                                                        .truncationMode(.tail)
                                                        .foregroundColor(AppStyles.primaryTextColor)
                                                        .underline()
                                                        .padding(.vertical, 2)
                                                        .padding(.horizontal, 4)
                                                        .background(AppStyles.secondaryTextColor.opacity(0.1)) // Zart abheben
                                                        .cornerRadius(4)
                                                }
                                                .contentShape(Rectangle())
                                            }
                                            .buttonStyle(LinkPressEffect())
                                            // Zeigt den Link als grauen Text an, wenn er nicht als URL geparst werden kann
                                        } else if let linkString = authority.link, !linkString.isEmpty {
                                            Text("Link: \(linkString)")
                                                .font(.caption)
                                                .foregroundColor(AppStyles.secondaryTextColor)
                                        }
                                    }
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                        Spacer()
                    } else if let errorMessage = profileViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("Keine Bundesland-Details verfügbar. Bitte wähle ein Bundesland in deinem Profil aus.")
                            .foregroundColor(AppStyles.secondaryTextColor)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Infos für \(profileViewModel.selectedStateDetails?.stateName ?? profileViewModel.homeStateName ?? "dein Bundesland")")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppStyles.backgroundGradient, for: .navigationBar) // Navigation Bar Hintergrund
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
        .onAppear {
            if profileViewModel.selectedStateDetails == nil ||
                profileViewModel.selectedStateDetails?.id != profileViewModel.userProfile?.homeStateId {
                Task {
                    await profileViewModel.fetchSelectedStateDetails()
                }
            }
        }
    }
}

#Preview {
    StateDetailView()
        .environmentObject(UserProfileViewModel())
}
