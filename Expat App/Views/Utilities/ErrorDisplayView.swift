//
//  ErrorDisplayView.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import SwiftUI

struct ErrorDisplayView: View {
    let title: String // Titel der Fehlermeldung (z.B. "Fehler")
    let message: String // Detailierte Fehlermeldung
    let retryAction: (() -> Void)? // Optional: Closure, die beim Tippen auf "Erneut versuchen" ausgeführt wird
    
    var body: some View {
        VStack(spacing: 15) { // Abstand zwischen Elementen
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(AppStyles.destructiveColor) // Rot für Fehler
                .padding(.bottom, 5)
            
            Text(title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor) // Primäre Textfarbe
            
            Text(message)
                .font(.caption)
                .foregroundColor(AppStyles.secondaryTextColor) // Sekundäre Textfarbe
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction { // Zeige Button nur, wenn eine Aktion bereitgestellt wird
                Button("Erneut versuchen") {
                    retryAction() // Führt die Closure aus
                }
                .padding(.top)
                .buttonStyle(.borderedProminent) // Oder dein primaryButtonStyle(), wenn passend
                .tint(AppStyles.buttonBackgroundColor) // Farbe des Buttons
                .foregroundColor(AppStyles.buttonTextColor) // Textfarbe des Buttons
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Füllt den gesamten verfügbaren Platz aus
    }
}

// MARK: - Preview
#Preview("Error Display") {
    ErrorDisplayView(title: "Verbindungsfehler", message: "Es konnte keine Verbindung zum Server hergestellt werden. Bitte überprüfe deine Internetverbindung und versuche es erneut.") {
        // Vorschau ohne Seiteneffekt.
    }
    .background(AppStyles.backgroundGradient.ignoresSafeArea())
}

//#Preview("Error Display No Retry") {
//    ErrorDisplayView(title: "Fehler", message: "Ein unbekannter Fehler ist aufgetreten.")
//        .background(AppStyles.backgroundGradient.ignoresSafeArea())
//}
