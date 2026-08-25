//
//  ProfileView.swift
//  Expat App
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @EnvironmentObject private var profileViewModel: UserProfileViewModel
    @EnvironmentObject private var accountDeletionViewModel: AccountDeletionViewModel
    @Binding var selectedTab: TabSelection

    @State private var editableDisplayName = ""
    @State private var isEditingDisplayName = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 20) {
                        if authenticationViewModel.isAnonymousUser {
                            guestCard
                        } else {
                            accountCard
                            stateCard
                        }

                        if let errorMessage = profileViewModel.errorMessage ?? accountDeletionViewModel.errorMessage {
                            messageView(errorMessage, color: AppStyles.destructiveColor)
                        } else if let successMessage = profileViewModel.successMessage ?? accountDeletionViewModel.successMessage {
                            messageView(successMessage, color: .green)
                        }

                        accountActions
                    }
                    .padding(.vertical)
                }
            }
            .background(AppStyles.backgroundGradient.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .overlay {
                if profileViewModel.isLoading || accountDeletionViewModel.isLoading {
                    ProgressView()
                        .tint(AppStyles.primaryTextColor)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert(
                authenticationViewModel.isAnonymousUser
                    ? "Gastkonto endgültig löschen?"
                    : "Konto endgültig löschen?",
                isPresented: $accountDeletionViewModel.showConfirmation
            ) {
                if accountDeletionViewModel.requiresPassword {
                    SecureField("Aktuelles Passwort", text: $accountDeletionViewModel.password)
                }
                Button("Löschen bestätigen", role: .destructive) {
                    Task { await accountDeletionViewModel.deleteAccount() }
                }
                Button("Abbrechen", role: .cancel) {
                    accountDeletionViewModel.cancelDeletion()
                }
            } message: {
                Text(accountDeletionViewModel.confirmationMessage)
            }
            .onAppear {
                editableDisplayName = profileViewModel.userProfile?.displayName ?? ""
                profileViewModel.clearMessages()
            }
            .onChange(of: profileViewModel.userProfile?.displayName) { _, newName in
                editableDisplayName = newName ?? ""
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Dein Konto")
                .font(.title2.bold())
                .foregroundColor(AppStyles.primaryTextColor)
            Spacer()
            Button {
                selectedTab = .settings
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
            }
            .foregroundColor(AppStyles.primaryTextColor)
            .accessibilityLabel("Einstellungen öffnen")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(AppStyles.backgroundGradient)
        .overlay(Divider(), alignment: .bottom)
    }

    private var guestCard: some View {
        profileCard(title: "Gastkonto") {
            Text("Als Gast kannst du Inhalte ansehen. Personalisierte Checklisten und Profildaten benötigen eine Registrierung.")
                .foregroundColor(AppStyles.secondaryTextColor)
        }
    }

    private var accountCard: some View {
        profileCard(title: "Kontodaten") {
            if isEditingDisplayName {
                TextField("Anzeigename", text: $editableDisplayName)
                    .textInputAutocapitalization(.words)
                    .padding(10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("Anzeigename")

                HStack {
                    Button("Abbrechen") {
                        editableDisplayName = profileViewModel.userProfile?.displayName ?? ""
                        isEditingDisplayName = false
                    }
                    Spacer()
                    Button("Speichern") {
                        Task {
                            await profileViewModel.updateDisplayName(editableDisplayName)
                            if profileViewModel.errorMessage == nil {
                                isEditingDisplayName = false
                            }
                        }
                    }
                    .disabled(editableDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            } else {
                valueRow(label: "Name", value: profileViewModel.userProfile?.displayName ?? "Nicht festgelegt")
                Button("Anzeigename ändern") {
                    isEditingDisplayName = true
                }
                .font(.callout)
            }

            if let email = authenticationViewModel.session?.email, !email.isEmpty {
                valueRow(label: "E-Mail", value: email)
            }
            if let createdAt = profileViewModel.userProfile?.createdAt {
                valueRow(label: "Registriert", value: createdAt.dateValue().formatted(date: .abbreviated, time: .omitted))
            }
        }
    }

    private var stateCard: some View {
        profileCard(title: "Bundesland") {
            Text(profileViewModel.homeStateName ?? "Nicht festgelegt")
                .foregroundColor(AppStyles.secondaryTextColor)

            HStack {
                Button("Bundesland ändern") {
                    profileViewModel.showStateSelection = true
                }
                Spacer()
                NavigationLink("Details") {
                    StateDetailView()
                }
            }
            .font(.callout)
        }
    }

    private var accountActions: some View {
        VStack(spacing: 12) {
            if !authenticationViewModel.isAnonymousUser {
                Button {
                    authenticationViewModel.signOut()
                } label: {
                    Label("Ausloggen", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .primaryButtonStyle()
                .accessibilityHint("Meldet das aktuelle Konto von diesem Gerät ab")
            }

            Button(role: .destructive) {
                accountDeletionViewModel.prepareDeletion()
            } label: {
                Label(
                    authenticationViewModel.isAnonymousUser ? "Gastkonto löschen" : "Konto löschen",
                    systemImage: "trash"
                )
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(AppStyles.destructiveColor, in: Capsule())
            .foregroundColor(AppStyles.destructiveTextColor)
            .accessibilityHint("Öffnet eine Bestätigung für die dauerhafte Kontolöschung")
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func profileCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppStyles.cellBackgroundColor.opacity(0.5), in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private func valueRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundColor(AppStyles.secondaryTextColor)
            Spacer()
            Text(value)
                .foregroundColor(AppStyles.primaryTextColor)
                .multilineTextAlignment(.trailing)
        }
    }

    private func messageView(_ message: String, color: Color) -> some View {
        Text(message)
            .font(.callout)
            .foregroundColor(color)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .accessibilityLabel(message)
    }
}

#Preview("ProfileView") {
    ProfileView(selectedTab: .constant(.profile))
        .environmentObject(AuthenticationViewModel())
        .environmentObject(UserProfileViewModel())
        .environmentObject(AccountDeletionViewModel())
}
