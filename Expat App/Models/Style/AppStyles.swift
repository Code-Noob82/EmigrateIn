//
//  AppStyles.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI

// MARK: - App Styles
// Eine Struktur, um wiederverwendbare Design-Elemente zu bündeln
// Angepasste Farben für den Verlauf, um besseren Kontrast mit hellem Text zu gewährleisten
struct AppStyles {
    static let gradientColors: [Color] = [
        Color(red: 0.1, green: 0.55, blue: 0.55), // Helleres Petrol für innen
        Color(red: 0.05, green: 0.45, blue: 0.45)   // Dunkleres Petrol für außen
    ]
    
    // Definiert den radialen Farbverlauf zentral
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Definiert die Textfarben zentral
    static let primaryTextColor = Color(red: 0.93, green: 0.95, blue: 0.96)
    static let secondaryTextColor = Color(white: 0.85)
    static let buttonTextColor = gradientColors.last ?? Color(red: 40, green: 100, blue: 40)
    static let buttonBackgroundColor = primaryTextColor // Fast weiß
    static let destructiveColor = Color(red: 0.72, green: 0.08, blue: 0.08)
    static let destructiveTextColor = Color.white
    
    // MARK: - NEU: Farben für Grid-Elemente
    // Eine passende Akzentfarbe, die mit Petrol harmoniert (z.B. ein helles Gold oder ein helles Türkis)
    static let accentColor = Color(red: 0.95, green: 0.75, blue: 0.3) // Ein helles Gold
    
    // Hintergrundfarbe der Gitterzelle (etwas dunkler als der Hintergrund, aber nicht zu dunkel)
    static let cellBackgroundColor = Color(white: 0.15).opacity(0.7) // Ein dunkles Grau mit Transparenz
    
    // Randfarbe für die Gitterzelle
    static let borderColor = Color(white: 0.3).opacity(0.5) // Ein etwas helleres Grau für den Rand
    
    // NEU: Globale Stilwerte für Buttons
    static let buttonHeight: CGFloat = 50
    static let primaryButtonFont: Font = .headline
    static let secondaryButtonFont: Font = .subheadline
    static let commonButtonCornerRadius: CGFloat = buttonHeight / 2 // Für Kapselform
    static let buttonCornerRadius: CGFloat = 20 // Für abgerundete Ecken
    
    static var cardBackgroundColor: Color {
            Color(UIColor.secondarySystemGroupedBackground) // Hintergrund für Karten
        }
}

extension AppStyles {
    struct PrimaryButton: ViewModifier {
        func body(content: Content) -> some View {
            content // Der Inhalt des Buttons (z.B. Text oder Label)
                .font(AppStyles.primaryButtonFont)
                .frame(height: AppStyles.buttonHeight)
                .frame(maxWidth: .infinity)
                .background(AppStyles.buttonBackgroundColor)
                .foregroundColor(AppStyles.buttonTextColor)
            //.clipShape(Capsule())
                .cornerRadius(AppStyles.buttonCornerRadius)
        }
    }
    struct SecondaryButton: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppStyles.secondaryButtonFont)
        }
    }
}

struct LinkPressEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Skaliert beim Drücken
            .opacity(configuration.isPressed ? 0.8 : 1.0)      // Macht es beim Drücken leicht transparent
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed) // Fügt eine sanfte Animation hinzu
    }
}

struct TextLinkButtonStyle: ButtonStyle {
    var textColor: Color = .blue // Standardfarbe für Links
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline) // Oder die gewünschte Schriftart
            .foregroundColor(textColor)
            .underline() // Fügt die Unterstreichung hinzu
            .opacity(configuration.isPressed ? 0.5 : 1.0) // Leichtes Dimmen beim Drücken
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        self.modifier(AppStyles.PrimaryButton())
    }
}

extension View {
    func secondaryButtonStyle() -> some View {
        self.modifier(AppStyles.SecondaryButton())
    }
}
