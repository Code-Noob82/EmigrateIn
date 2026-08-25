//
//  NotificationSettingsSectionView.swift
//  Expat App
//

import SwiftUI

struct NotificationSettingsSectionView: View {
    @AppStorage("notifications.general") private var generalNotificationsEnabled = true
    @AppStorage("notifications.appNews") private var appNewsEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Benachrichtigungen")
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 5)

            SettingsRow {
                Toggle("Benachrichtigungen in der App", isOn: $generalNotificationsEnabled)
                    .tint(AppStyles.accentColor)
                    .foregroundColor(AppStyles.primaryTextColor)
                    .accessibilityHint("Aktiviert oder deaktiviert alle gespeicherten Benachrichtigungseinstellungen")
            }

            SettingsRow {
                Toggle("App-Neuigkeiten", isOn: $appNewsEnabled)
                    .tint(AppStyles.accentColor)
                    .foregroundColor(generalNotificationsEnabled ? AppStyles.primaryTextColor : AppStyles.secondaryTextColor)
                    .disabled(!generalNotificationsEnabled)
            }

            SettingsRow {
                Label("Weitere Benachrichtigungen folgen mit den Community-Funktionen.", systemImage: "clock.badge")
                    .font(.callout)
                    .foregroundColor(AppStyles.secondaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .background(AppStyles.cellBackgroundColor.opacity(0.5), in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

#Preview {
    NotificationSettingsSectionView()
}
