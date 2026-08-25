//
//  OnboardingStepView.swift
//  Expat App
//
//  Created by Dominik Baki on 25.04.25.
//

import SwiftUI

// MARK: - Wiederverwendbare Onboarding Step View

// Eine wiederverwendbare View für einzelne Schritte im Onboarding-Prozess.
struct OnboardingStepView: View {
    @ScaledMetric private var illustrationHeight = 150
    // Daten für diesen spezifischen Onboarding-Schritt
    let imageName: String
    let headline: String
    let bodyText: String
    let pageIndex: Int // Index dieser Seite (z.B. 0, 1, 2)
    let totalPages: Int // Gesamtanzahl der Seiten
    
    // Aktion für den Button (wird von außen übergeben)
    var buttonAction: () -> Void = {}
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: illustrationHeight)
                    .padding(.bottom, 30)
                    .foregroundColor(AppStyles.primaryTextColor)
                    .accessibilityHidden(true)
                // Überschrift
                Text(headline)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppStyles.primaryTextColor)
                    .multilineTextAlignment(.center)
                // Beschreibungstext
                Text(bodyText)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(AppStyles.secondaryTextColor)
                    .multilineTextAlignment(.center)
                Spacer()
                Spacer()
                // Page Indicator (Punkte) - Dynamisch
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == pageIndex ? AppStyles.primaryTextColor : AppStyles.secondaryTextColor.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Seite \(pageIndex + 1) von \(totalPages)")
                .padding(.bottom, 20)
                
                Button(pageIndex == totalPages - 1 ? "Los geht's!" : "Weiter") {
                    buttonAction() // Führt die übergebene Aktion aus
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppStyles.buttonBackgroundColor)
                .foregroundColor(AppStyles.buttonTextColor)
                .clipShape(Capsule())
                .padding(.horizontal)
                
                Spacer().frame(height: 20)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
// MARK: - Preview

#Preview("Einzelner Step") {
    ZStack {
        AppStyles.backgroundGradient.ignoresSafeArea()
        // Vorschau für einen einzelnen Schritt
        OnboardingStepView(
            imageName: "info.circle.fill",
            headline: "Infos an einem Ort",
            bodyText: "Visa, Behörden, Wohnen, Schule – behaltet den Überblick! EmigrateIn bündelt alle wichtigen Infos.",
            pageIndex: 1, // Zweite Seite
            totalPages: 4  // Vier Seiten insgesamt
        )
    }
}

#Preview("Gesamter Flow") {
    ZStack {
        AppStyles.backgroundGradient.ignoresSafeArea()
        // Vorschau für den gesamten Onboarding-Flow
        OnboardingContainerView(finishAction: {
            // Vorschau ohne Seiteneffekt.
        })
    }
}
