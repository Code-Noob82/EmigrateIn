//
//  StateSelectionView.swift
//  Expat App
//
//  Created by Dominik Baki on 29.04.25.
//

import SwiftUI

// MARK: - State Selection View

struct StateSelectionView: View {
    @EnvironmentObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) var dismiss // Zum Schließen des Sheets
    
    var body: some View {
        ZStack {
            AppStyles.backgroundGradient
                .ignoresSafeArea()
            
            NavigationStack {
                VStack(spacing: 20) {
                    
                    // Hauptüberschrift
                    Text("Wähle dein Bundesland")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppStyles.primaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    // Ausführlicher Hinweistext
                    Text("Diese Angabe hilft uns, dir spezifische Informationen für Behörden, Apostillen und mehr in deinem Bundesland anzuzeigen. \nDu kannst deine Auswahl jederzeit in deinem Profil ändern.")
                        .font(.callout)
                        .foregroundColor(AppStyles.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // Picker zur Auswahl des Bundeslandes
                    Picker("Bundesland", selection: $viewModel.selectedStateID) {
                        Text("Bitte auswählen").tag(nil as String?) // Platzhalter
                            .foregroundColor(AppStyles.primaryTextColor)
                        
                        ForEach(viewModel.germanStates) { state in
                            // Zeigt den Namen an, speichert aber die ID (z.B. "BW")
                            Text(state.stateName).tag(state.id as String?)
                                .foregroundColor(.black)
                        }
                    }
                    .pickerStyle(.inline)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .tint(AppStyles.primaryTextColor)
                    
                    Spacer()
                    
                    Button("Speichern & Weiter") {
                        Task {
                            await viewModel.saveSelectedState()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppStyles.buttonBackgroundColor)
                    .foregroundColor(AppStyles.buttonTextColor)
                    .clipShape(Capsule()) // Jetzt eine Kapselform!
                    .disabled(viewModel.selectedStateID == nil ||
                              viewModel.isLoading) // Deaktivieren, wenn nichts ausgewählt oder am Laden
                    // Zusätzliche visuelle Deaktivierung, falls der Button-Stil nicht greift
                    .opacity(viewModel.selectedStateID == nil ||
                             viewModel.isLoading ? 0.6 : 1.0)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(AppStyles.destructiveColor)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .navigationTitle("Profil vervollständigen")
                .navigationBarTitleDisplayMode(.inline)
                .background(AppStyles.backgroundGradient)
                .toolbarBackground(AppStyles.backgroundGradient, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(AppStyles.primaryTextColor.isDark ? .light : .dark, for: .navigationBar)
                .overlay { // Zeigt Ladeindikator
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppStyles.primaryTextColor)
                    }
                }
                // Schließen-Button in der Toolbar
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Abbrechen") {
                            dismiss()
                        }
                        .foregroundColor(AppStyles.primaryTextColor)
                    }
                }
            }
        }
    }
}

#Preview("State Selection View") {
    StateSelectionView()
        .environmentObject(UserProfileViewModel())
}
