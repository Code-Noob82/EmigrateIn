//
//  InfoContentGridItemView.swift
//  Expat App
//
//  Created by Dominik Baki on 28.05.25.
//

import SwiftUI
import MarkdownUI

struct InfoContentGridItemView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel // Benötigt für isAnonymousUser
    let contentItem: InfoContent
    @Binding var showRegistrationPrompt: Bool // Binding, um den Alert in der Eltern-View zu steuern
    @Binding var tappedContentItem: InfoContent? // Binding, um das getappte Item zu speichern
    
    var body: some View {
        // Die Logik für NavigationLink vs. Button ist hier gekapselt
        Group {
            if authViewModel.isAnonymousUser {
                // Anonym: Zeigt einen Button, der den Alert auslöst
                Button {
                    self.tappedContentItem = contentItem
                    self.showRegistrationPrompt = true // Zeigt den Alert an
                } label: {
                    gridItemContent
                }
                .buttonStyle(.plain) // Lässt den Button wie ein Grid-Element aussehen
            } else {
                // Nicht anonym (registriert): Zeigt normalen NavigationLink
                NavigationLink(value: contentItem) { // Löst .navigationDestination aus
                    gridItemContent
                }
                .buttonStyle(.plain) // Um das Standard-Button-Styling des NavigationLinks zu entfernen
            }
        }
        // Zusätzlicher Modifikator, falls du den "Tap"-Effekt für die Grid-Elemente möchtest
        .buttonStyle(LinkPressEffect()) // Optional: Für einen visuellen Feedback beim Tippen
        .accessibilityLabel(contentItem.title)
        .accessibilityHint(
            authViewModel.isAnonymousUser
                ? "Erfordert eine Anmeldung"
                : "Öffnet den vollständigen Inhalt"
        )
    }
    
    // Inhalt des Grid-Elements (visueller Teil)
    private var gridItemContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(contentItem.title)
                .font(.headline)
                .foregroundColor(AppStyles.primaryTextColor)
                .multilineTextAlignment(.leading) // Links ausgerichtet im Grid
                .lineLimit(2) // Begrenzt Titel auf 2 Zeilen
            
            Text(truncatedContent(contentItem.content, maxLength: 80)) // Kürzerer Inhalt für Grid-Ansicht
                .markdownTheme(.basic)
                .font(.caption)
                .foregroundColor(AppStyles.secondaryTextColor)
                .lineLimit(3) // Begrenzt die Vorschau auf 3 Zeilen
                .multilineTextAlignment(.leading) // Links ausgerichtet im Grid
            
            Spacer() // Schiebt Inhalt nach oben
            
            // Optional: Ein "Weiterlesen"-Indikator, falls der Inhalt gekürzt wurde
            if contentItem.content.count > 80 { // Einfache Prüfung, ob gekürzt wurde
                Text("Weiterlesen...")
                    .font(.caption2)
                    .foregroundColor(AppStyles.accentColor) // Akzentfarbe für den Link
            }
            // Wenn der Benutzer anonym ist, zeigen wir ein Schloss-Icon an
            if authViewModel.isAnonymousUser {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundColor(AppStyles.secondaryTextColor)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(AppStyles.cellBackgroundColor.opacity(0.5)) // Etwas Transparenz
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppStyles.borderColor.opacity(0.8), lineWidth: 1)
        )
    }
    
    // Diese Funktion kopierst du aus deiner InfoContentListView
    private func truncatedContent(_ content: String, maxLength: Int) -> String {
        var plainText = content
            .replacingOccurrences(of: #"(\*\*|__)(.*?)\1"#, with: "$2", options: .regularExpression)
            .replacingOccurrences(of: #"(\*|_)(.*?)\1"#, with: "$2", options: .regularExpression)
            .replacingOccurrences(of: #"^#+\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"^-+\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"^\*\s+"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"`(.*?)`"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"\[(.*?)\]\((.*?)\)"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: "\n", with: " ")
            
        plainText = plainText.replacingOccurrences(of: #" {2,}"#, with: " ", options: .regularExpression)
        
        if plainText.count <= maxLength {
            return plainText
        }
        
        let endIndex = plainText.index(plainText.startIndex, offsetBy: maxLength, limitedBy: plainText.endIndex) ?? plainText.endIndex
        var truncated = String(plainText[..<endIndex])
        
        if let lastSentenceEnd = truncated.rangeOfCharacter(from: CharacterSet(charactersIn: ".?!"), options: .backwards) {
            let sentenceEndIndex = lastSentenceEnd.upperBound
            if truncated.distance(from: truncated.startIndex, to: sentenceEndIndex) > maxLength / 2 {
                truncated = String(truncated[..<sentenceEndIndex])
            }
        } else {
            if let lastSpace = truncated.lastIndex(of: " ") {
                truncated = String(truncated[..<lastSpace])
            }
        }
        
        return truncated + "..."
    }
}

//#Preview {
//    InfoContentGridItemView()
//}
