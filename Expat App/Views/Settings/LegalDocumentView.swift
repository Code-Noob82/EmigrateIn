//
//  LegalDocumentView.swift
//  Expat App
//

import MarkdownUI
import SwiftUI

enum LegalDocument {
    case privacy
    case terms

    var title: String {
        switch self {
        case .privacy: "Datenschutzinformationen"
        case .terms: "Nutzungsbedingungen"
        }
    }

    var content: String {
        switch self {
        case .privacy:
            return """
            # Datenschutzinformationen – Entwurf

            **Stand: 24. August 2026**

            EmigrateIn verarbeitet für angemeldete Nutzer die E-Mail-Adresse, einen optionalen Anzeigenamen, das gewählte Bundesland und den Checklistenfortschritt. Bei einem Gastkonto verwendet Firebase eine anonyme Nutzerkennung.

            ## Eingesetzte Dienste

            - **Google Firebase:** Anmeldung, Nutzerprofile, App-Inhalte und Checklistenfortschritt.
            - **Google Sign-In:** nur bei freiwilliger Anmeldung mit einem Google-Konto.
            - **Auswärtiges Amt:** öffentliche Vertretungsdaten; die App übermittelt dabei keine Profildaten.

            Nutzer können ihr Konto im Profil löschen. Dabei entfernt die App das Nutzerprofil, den Checklistenfortschritt und anschließend das Firebase-Authentifizierungskonto.

            **Vor einer Veröffentlichung müssen eine ladungsfähige Kontaktadresse, Rechtsgrundlagen, Aufbewahrungsfristen und die vollständigen Angaben zu Auftragsverarbeitern rechtlich geprüft und ergänzt werden.**
            """
        case .terms:
            return """
            # Nutzungsbedingungen – Entwurf

            **Stand: 24. August 2026**

            EmigrateIn stellt allgemeine Informationen und organisatorische Checklisten für Auswanderungsvorhaben bereit. Die Inhalte ersetzen keine Rechts-, Steuer-, Medizin- oder Einwanderungsberatung.

            Behördliche Regeln, Kontaktdaten und Kosten können sich ändern. Nutzer sollten entscheidende Angaben anhand der verlinkten offiziellen Quellen prüfen.

            Für einen produktiven Betrieb müssen Anbieterangaben, Haftungsregelungen, Verfügbarkeit, zulässige Nutzung und das anwendbare Recht vor Veröffentlichung rechtlich geprüft und vervollständigt werden.
            """
        }
    }
}

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            Markdown(document.content)
                .markdownTheme(.basic)
                .foregroundColor(AppStyles.primaryTextColor)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppStyles.backgroundGradient.ignoresSafeArea())
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Häufige Fragen")
                    .font(.title2.bold())
                Group {
                    Text("Wo wird mein Checklistenfortschritt gespeichert?").font(.headline)
                    Text("Für registrierte Nutzer wird der Fortschritt im zugehörigen Firebase-Konto gespeichert.")
                    Text("Kann ich EmigrateIn als Gast nutzen?").font(.headline)
                    Text("Ja. Persönliche Checklisten und Profildaten benötigen jedoch eine Registrierung.")
                    Text("Wie lösche ich mein Konto?").font(.headline)
                    Text("Im Bereich Profil befindet sich die Funktion „Konto löschen“.")
                }
                .foregroundColor(AppStyles.primaryTextColor)

                if let supportURL = URL(string: "https://github.com/Code-Noob82/EmigrateIn/issues/new") {
                    Link("Supportanfrage auf GitHub erstellen", destination: supportURL)
                        .font(.headline)
                        .accessibilityHint("Öffnet GitHub im Browser")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppStyles.backgroundGradient.ignoresSafeArea())
        .navigationTitle("FAQ und Kontakt")
        .navigationBarTitleDisplayMode(.inline)
    }
}
