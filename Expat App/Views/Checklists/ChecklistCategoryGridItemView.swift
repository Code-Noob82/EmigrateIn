//
//  ChecklistCategoryGridItemView.swift
//  Expat App
//
//  Created by Dominik Baki on 28.05.25.
//

import SwiftUI

struct ChecklistCategoryGridItemView: View {
    let category: ChecklistCategory // Nimmt eine ChecklistCategory als Input
    
    var body: some View {
        VStack {
            // Optional: Ein Icon hinzufügen, wenn ChecklistCategory ein iconName hätte
            // Wie bei InfoCategory, ein Image(systemName: category.iconName) anzeigen
            // Da ChecklistCategory aktuell kein iconName hat, lasse ich es hier weg.
            // Falls Icons hinzufügen -> ChecklistCategory-Modell erweitern.
            
            Text(category.title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
                .multilineTextAlignment(.center) // Zentriert für Grid-Element
                .lineLimit(2) // Begrenzt Titel auf 2 Zeilen für einheitliche Höhe
            
            // Optional: Wenn du eine kurze Beschreibung/Subtitle in den Grid-Elementen haben möchtest,
            // könntest du diese hier hinzufügen. Aktuell hast du sie für die Liste entfernt.
            // Zum Beispiel:
            // if let description = category.description, !description.isEmpty {
            //     Text(description)
            //         .font(.caption)
            //         .foregroundColor(AppStyles.secondaryTextColor)
            //         .multilineTextAlignment(.center)
            //         .lineLimit(2)
            // } else {
            //     Spacer(minLength: 20) // Platzhalter für Konsistenz
            // }
            
            Spacer() // Schiebt den Inhalt nach oben
            
            // Du könntest hier ein kleines Icon oder einen Indikator für "Details" hinzufügen
            // Image(systemName: "arrow.right.circle.fill")
            //     .font(.subheadline)
            //     .foregroundColor(AppStyles.accentColor)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160)
        // MARK: - Hintergrund und Rand
        .background(AppStyles.cellBackgroundColor.opacity(0.5)) // Etwas Transparenz
        .cornerRadius(15) // Abgerundete Ecken
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5) // Leichter Schatten
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppStyles.borderColor.opacity(0.8), lineWidth: 1) // Rand mit Transparenz
        )
        .accessibilityElement(children: .combine)
    }
}

//#Preview {
//    ChecklistCategoryGridItemView()
//}
