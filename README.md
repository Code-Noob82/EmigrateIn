# EmigrateIn - Expat Familien App (MVP)

**"EmigrateIn - Dein smarter Weg ins Ausland"**

## Projektbeschreibung

**EmigrateIn** ist eine native iOS-App, die als Minimum Viable Product (MVP) im Rahmen des **Abschlussprojekts Modul 3 - App-Entwicklung iOS - am Syntax Institut** entwickelt wurde.

## Ziel der App

Deutschen Familien den komplexen Prozess der Auswanderung ins Ausland zu erleichtern. Die App soll als zentraler Informations-Hub und Begleiter dienen, um Unsicherheiten zu reduzieren und die Vorbereitung sowie die ersten Schritte nach der Ankunft zu strukturieren.

## Problemstellung

Die Auswanderung, besonders mit Familie, ist mit zahlreichen bürokratischen Hürden, Informationslücken und organisatorischem Aufwand verbunden. Informationen sind oft verstreut, veraltet oder nicht spezifisch auf die Bedürfnisse von Familien zugeschnitten.

## Lösungsansatz (MVP)

Die App bündelt relevante, recherchierte Informationen und interaktive Checklisten für die kritischen Phasen der Vorbereitung in Deutschland und der Ankunft im Zielland. Sie nutzt Firebase als Backend und integriert eine externe API zur Anzeige relevanter Kontaktdaten.

## Was macht die App anders/besser?

Im Gegensatz zu allgemeinen Foren oder Webseiten, konzentriert sich EmigrateIn **gezielt auf deutsche Familien und inital den Start in Südzypern**. Sie bietet nicht nur Informationen, sondern **verknüpft diese direkt mit praktischen, interaktiven Checklisten**. Besonderer Wert wird auf die **Verlässlichkeit der Informationen** gelegt, indem auf offizielle Quellen verwiesen und der Informationsstand transparent gemacht wird.

## Kern-Features (MVP V1.0 - Fokus: Deutsche Familien nach Südzypern)

- [X] **Onboarding:** Nach dem Start durchläuft der Nutzer ein kurzes Onboarding. Über eine Hauptnavigation (Tab Bar) kann er auf die verschiedenen Info-Kategorien und Checklisten zugreifen. Informationen können gelesen, Checklistenpunkte abgehakt werden. Die Botschaftsinformationen werden dynamisch über eine API geladen.
- [X] **Info-Hub**: Ein strukturierter Bereich mit aufbereiteten Informationen zu essenziellen Themen:
- Visa & Einreise *(MEU1/Yellow Slip, MEU2)*
- Ankunft & Erste Schritte *(Behördengänge: TIN, Sozialversicherung, GESY)*
- Wohnen *(Mieten/Kaufen Basics, Mietvertrag, Nebenkosten)*
- Bildung & Familie *(Schulsystem Überblick, Anmeldung Basics)*
- Gesundheitssystem *(GESY Überblick, Registrierung, Arztsuche Basics)*
- Kosten & Budget *(Statische Übersicht Lebenshaltungskosten, Einmalkosten)*
- Kontakte & Sicherheit *(Botschafts-Info, Notfallnummern, Hinweise zur Sicherheitsrecherche)*
- [X] **Interaktive Checklisten:** Detaillierte, abharkbare Checklisten für die Phasen:
- Vorbereitung in Deutschland
- Ankunft & Erste Schritte in Zypern
- Speicherung des Fortschritts lokal via Firebase Authentication.
- [X] **Botschafts-Information:** Abruf und Anzeige der Kontaktdaten der Deutschen Botschaft in Nikosia über die OpenData-API des Auswärtigen Amtes `(travelwarning.api.bund.dev)`.
- [X] **Fehlerbehandlung:** Nutzerfreundliche Anzeige von Fehlern *(z.B. bei Netzwerkproblemen oder API-Fehlern)* mittels Alerts.

## Design

<p>
  <img src="./img/Screen1.png" width="200">
  <img src="./img/Screen2.png" width="200">
  <img src="./img/Screen3.png" width="200">
  <img src="./img/Screen4.png" width="200">
  <img src="./img/Screen5.png" width="200">
  <img src="./img/Screen6.png" width="200">
</p>

## Projektstruktur & Architektur Übersicht

### 1. Architektur: MVVM (Model-View-ViewModel)

Die App folgt dem **MVVM (Model-View-ViewModel)** Architekturmuster, das sich gut für SwiftUI eignet und eine klare Trennung der Verantwortlichkeiten fördert:

- **Model:** Repräsentiert die Daten der App (z.B. `InfoCategory`, `ChecklistItem`, `Embassy`). Diese Strukturen sind `Codable`, um Daten aus Firebase oder APIs zu parsen. Sie enthalten keine Logik zur Darstellung oder Datenbeschaffung.
  -  *Ordner:* `Models`
 
- **View:** Repräsentiert die Benutzeroberfläche (UI), die der Nutzer sieht.
  - *Ordner:* `Views` *(weiter unterteilt nach Features, z.B. `Onboarding`, `InfoHub`, `Checklists`)*

- **ViewModel:** Dient als Bindeglied zwischen Model und View. Es bereitet Daten aus dem Model für die Anzeige in der View auf, hält den Zustand der View *(z.B. Ladezustand, Eingaben)* und verarbeitet Benutzeraktionen. ViewModels sind `ObservableObject`, damit die Views auf Änderungen reagieren können. Sie enthalten die Präsentationslogik und rufen Repositories auf, um Daten zu laden oder zu speichern.
  - *Ordner:* `ViewModels`
 
### 2. Abstraktion der Datenquelle: Repository Pattern

Um die ViewModels von der konkreten Datenquelle (Firebase, API, UserDefaults) zu entkoppeln und die Testbarkeit zu verbessern, setze ich das Repository Pattern ein:

- **Repositories:** Diese Klasse kapselt die Logik für den Datenzugriff. Es gibt z.B. ein `ContentRepository`, das für das Laden von Infos und Checklisten aus Firestore zuständig ist, und einem `EmbassyRepository`)*, das den API-Call zum Auswärtigen Amt durchführt. Die ViewModels kommunizieren nur mit diesen Repositories/Services, nicht direkt mit Firebase oder `URLSession`.

  - *Ordner:* `Repositories`

## Technologie-Stack

- **Plattform:** iOS
- **Sprache:** Swift
- **UI-Framework:** SwiftUI
- **Architektur:** MVVM *(Model-View-ViewModel)*
- **Backend:** Google Firebase
  - Datenbank: Firestore *(für App-Inhalte wie Infos & Checklisten)*
  - Authentifizierung: Firebase Authentication *(Optional für MVP, z.B. zur Speicherung des Checklisten-Status)*
- **API-Anbindung:** `URLSession` mit `async/await` für den Aufruf der Auswärtiges-Amt-API.
- **Daten-Parsing:** `Codable`für JSON-Daten aus Firebase und der API.
- **Lokale Daten:** `SwiftData`für einfache Einstellungen.

### Externe Abhängigkeiten / Frameworks
Diese App nutzt externe Bibliotheken, die über den **Swift Package Manager (SPM)** eingebunden werden:

1. FirebaseAuth:
   - Dies ist das Firebase Authentication SDK, das Funktionen für die Benutzerauthentifizierung (Anmeldung, Registrierung, Abmeldung etc.) bereitstellt.
3. FirebaseFirestore:
   - Dies ist das Firebase Firestore SDK, das den Zugriff auf die NoSQL-Cloud-Datenbank Firestore ermöglicht.
5. GoogleSignIn:
   - Dies ist das Google Sign-In SDK, das die Anmeldung mit Google-Konten in der App ermöglicht.
8. GoogleSignInSwift:
   - Dies ist eine Swift-spezifische Erweiterungsbibliothek für das Google Sign-In SDK, die oft für eine einfachere Integration mit SwiftUI verwendet wird.

## Ausblick

### Geplante zukünftige Erweiterungen

- [ ] **Community & Austausch:**
 - Ziel: Schaffung einer Plattform, auf der sich auswandernde und bereits ausgewanderte Familien vernetzen, Fragen stellen und Erfahrungen austauschen können.
 - Features: Integriertes Forum (nach Themen/Regionen sortiert), private Chat-Funktionen, Möglichkeit zur Erstellung von Nutzerprofilen.
- [ ] **Interaktiver Budgetplaner:**
 - Ziel: Familien ein Werkzeug an die Hand geben, um die Kosten der Auswanderung und des Lebens im Ausland detailliert zu planen und zu verfolgen.
 - Features: Eingabe von Einnahmen/Ausgaben, vordefinierte Kostenkategorien mit Schätzwerten für Zypern (später auch andere Länder), Vergleich Plan vs. IST, Währungsumrechner (falls nicht schon im MVP).
- [ ] **Detaillierte Verzeichnisse & Empfehlungen:**
 - Ziel: Nutzern den Zugang zu geprüften, lokalen Dienstleistern und wichtigen Kontakten erleichtern.
 - Features: Durchsuchbare Verzeichnisse für Ärzte (filterbar nach Sprache/GESY), Anwälte (mit Spezialisierung), Steuerberater, Immobilienmakler, Übersetzer, internationale Schulen etc. – potenziell mit Nutzerbewertungen.
- [ ] **Erweiterte Inhalte & Themen:**
 - Ziel: Die Informationsbasis über die Ankunftsphase hinaus erweitern.
 - Features: Detaillierte Abschnitte zu "Arbeiten als Angestellter" (Jobsuche, Gehälter, Arbeitskultur), Firmengründung (Ltd.), Steuersystem (Non-Dom etc.), weiterführende Bildung, kulturelle Integration, Freizeitgestaltung für Familien.
- [ ] **Nützliche Tools & Alltagshelfer:**
 - Ziel: Kleine Helfer für den Alltag im neuen Land integrieren.
 - Features: Basis-Vokabeltrainer (Griechisch), "Fakten über Zypern", Feiertagskalender, integrierte Suchfunktion innerhalb der App-Inhalte.
- [ ] **Expansion auf weitere Länder:**
 - Ziel: Die App für Auswanderer in andere beliebte Zielländer verfügbar machen.
 - Features: Schrittweise Ergänzung der Inhalte (Infos, Checklisten, Verzeichnisse) für weitere Länder, beginnend mit europäischen Zielen.
- [ ] **(Langfristige Vision) Plattform für Dienstleistungen:**
 - Ziel: Eine Brücke zwischen Auswanderungswilligen und erfahrenen Expats oder professionellen Dienstleistern schaffen.
 - Features: Möglichkeit für geprüfte Anbieter, ihre Unterstützungsleistungen (Beratung, Behördenhilfe etc.) auf der Plattform anzubieten (ggf. mit Buchungs-/Zahlungsfunktion).

Dieser Ausblick zeigt die geplante Entwicklung von einer fokussierten Starthilfe zu einer umfassenden Ressource und Community für auswandernde Familien. Die Priorisierung dieser Features wird sich am Nutzerfeedback und den verfügbaren Ressourcen orientieren.

## Autor

**Dominik Baki**, Student am **Syntax Institut** im Kurs Fachkraft für App-Entwicklung (iOS & Android).

## Danksagung

- Vielen Dank an [Florian Rhein, Renan Wurster, Anna Hoff] für die unermüdliche Unterstützung und Hilfe bei jeglichem Problem. Lieben Dank auch an meine Kursbetreuerin [Lisa Kipp] für die Betreuung, immer guter Laune und Hilfe bei allen Fragen rund um den Kurs.
- Inspiration und erste Informationen aus den Ressourcen von [AuswandernHilft.de].
- Daten der deutschen Vertretungen bereitgestellt durch die OpenData-Schnittstelle des Auswärtigen Amtes.
- Backend-Dienste bereitgestellt durch Google Firebase.
