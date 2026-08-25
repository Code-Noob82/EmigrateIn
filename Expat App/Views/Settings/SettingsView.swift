//
//  SettingsView.swift
//  Expat App
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedThemeRawValue = AppTheme.system.rawValue

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRawValue) ?? .system
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 20) {
                        NotificationSettingsSectionView()
                        appearanceCard
                        legalCard
                        supportCard
                        versionCard
                    }
                    .padding(.vertical)
                }
            }
            .background(AppStyles.backgroundGradient.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(colorScheme(for: selectedTheme))
        }
    }

    private var header: some View {
        HStack {
            Text("Einstellungen")
                .font(.title2.bold())
                .foregroundColor(AppStyles.primaryTextColor)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(AppStyles.backgroundGradient)
        .overlay(Divider(), alignment: .bottom)
    }

    private var appearanceCard: some View {
        settingsCard(title: "Darstellung") {
            SettingsRow {
                Menu {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            selectedThemeRawValue = theme.rawValue
                        } label: {
                            Label(theme.rawValue, systemImage: theme.icon)
                        }
                    }
                } label: {
                    HStack {
                        Label("Theme", systemImage: selectedTheme.icon)
                            .foregroundColor(AppStyles.primaryTextColor)
                        Spacer()
                        Text(selectedTheme.rawValue)
                            .foregroundColor(AppStyles.secondaryTextColor)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(AppStyles.secondaryTextColor)
                    }
                }
                .accessibilityLabel("Darstellung: \(selectedTheme.rawValue)")
            }
        }
    }

    private var legalCard: some View {
        settingsCard(title: "Rechtliches") {
            SettingsRow {
                NavigationLink {
                    LegalDocumentView(document: .privacy)
                } label: {
                    navigationLabel("Datenschutzinformationen", systemImage: "hand.raised.fill")
                }
            }
            SettingsRow {
                NavigationLink {
                    LegalDocumentView(document: .terms)
                } label: {
                    navigationLabel("Nutzungsbedingungen", systemImage: "doc.text.fill")
                }
            }
        }
    }

    private var supportCard: some View {
        settingsCard(title: "Hilfe und Support") {
            SettingsRow {
                NavigationLink {
                    SupportView()
                } label: {
                    navigationLabel("FAQ und Kontakt", systemImage: "questionmark.circle.fill")
                }
            }
            SettingsRow {
                if let feedbackURL = URL(string: "https://github.com/Code-Noob82/EmigrateIn/issues/new") {
                    Link(destination: feedbackURL) {
                        navigationLabel("Feedback geben", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .accessibilityHint("Öffnet GitHub zum Erstellen einer Rückmeldung")
                }
            }
        }
    }

    private var versionCard: some View {
        settingsCard(title: "Über die App") {
            SettingsRow {
                HStack {
                    Text("Version")
                        .foregroundColor(AppStyles.primaryTextColor)
                    Spacer()
                    Text("\(appVersion) (\(buildNumber))")
                        .foregroundColor(AppStyles.secondaryTextColor)
                }
            }
        }
    }

    @ViewBuilder
    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 5)
            content()
        }
        .background(AppStyles.cellBackgroundColor.opacity(0.5), in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private func navigationLabel(_ title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .foregroundColor(AppStyles.primaryTextColor)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(AppStyles.secondaryTextColor)
                .accessibilityHidden(true)
        }
    }

    private func colorScheme(for theme: AppTheme) -> ColorScheme? {
        switch theme {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }
}

#Preview {
    SettingsView()
}
