# EmigrateIn

EmigrateIn ist eine native iOS-App für deutsche Familien, die einen Umzug ins Ausland vorbereiten. Der aktuelle MVP bündelt Informationen, persönliche Checklisten, Bundesland-Inhalte und Kontaktdaten deutscher Auslandsvertretungen.

## Funktionsumfang

- Anmeldung per E-Mail, Google oder als Gast
- Informationsbereiche aus Firestore
- persönliche Checklisten mit nutzerbezogenem Fortschritt
- Profil und Auswahl des deutschen Bundeslands
- Daten deutscher Auslandsvertretungen über die OpenData-Schnittstelle des Auswärtigen Amts
- lokale Einstellungen für Darstellung und Benachrichtigungswünsche
- Kontolöschung mit erneuter Anmeldung für E-Mail- und Google-Konten
- Registrierung eines Gastkontos durch Verknüpfung mit E-Mail oder Google; die bestehende UID bleibt erhalten

## Architektur

Die App verwendet SwiftUI und MVVM. Zuständigkeiten sind nach Funktionen getrennt:

- `AuthenticationViewModel`: Anmeldung, Registrierung, Abmeldung und Sitzungsstatus
- `UserProfileViewModel`: Profil, Bundesland und zugehörige Inhalte
- `AccountDeletionViewModel`: Bestätigung, erneute Anmeldung und Kontolöschung
- `ContentRepository`: Firestore-Inhalte und Checklistenstatus
- `UserProfileRepository`: Profildaten und nutzerbezogene Löschung
- `EmbassyRepository`: OpenData-Schnittstelle des Auswärtigen Amts
- `FirebaseAuthenticationService`: Firebase Authentication und Google Sign-In

Protokolle kapseln die Dienste und Repositories. Dadurch können die fachlichen ViewModel-Abläufe ohne Firebase-Verbindung getestet werden.

## Voraussetzungen

- Xcode mit iOS-18-SDK oder neuer
- SwiftLint für die lokale Build-Prüfung: `brew install swiftlint`
- Zugriff auf das konfigurierte Firebase-Projekt

Swift-Pakete werden beim ersten Build über Swift Package Manager geladen.

## Firebase-Konfiguration

Die maßgebliche Konfiguration liegt als `GoogleService-Info.plist` im Repository und enthält die Angaben für Firebase und Google Sign-In. Weitere gleichnamige Dateien außerhalb des Repositorys dürfen nicht ungeprüft darüberkopiert werden.

Alle Checklistenstände verwenden ausschließlich diesen Pfad:

```text
user_checklist_states/{userId}/completed_items/{itemId}
```

Die zugehörigen Zugriffsregeln stehen in `firestore.rules`. Vor einem produktiven Einsatz müssen sie im vorgesehenen Firebase-Projekt geprüft und veröffentlicht werden:

```bash
firebase deploy --only firestore:rules --project expat-family-app --dry-run
firebase deploy --only firestore:rules --project expat-family-app
```

## Build und Tests

```bash
xcodebuild \
  -project "Expat App.xcodeproj" \
  -scheme "Expat App" \
  -sdk iphonesimulator \
  CODE_SIGNING_ALLOWED=NO \
  build
```

Die Unit-Tests prüfen Passwortabgleich, Sitzungsbeobachtung, Profilerstellung mit Aufforderung zur Bundeslandauswahl und Kontolöschung. Der UI-Test prüft den Wechsel zwischen den ersten Onboarding-Seiten und deren zugängliche Bezeichnungen.

## Offene GitHub-Issues

Der Refactor berücksichtigt die derzeit offenen Issues:

- [#1 Firestore-Pfade](https://github.com/Code-Noob82/EmigrateIn/issues/1): einheitlicher Pfad und passende Eigentümerregeln
- [#2 Rechtliche Inhalte](https://github.com/Code-Noob82/EmigrateIn/issues/2): Datenschutz- und Nutzungsbedingungen sind in den Einstellungen technisch erreichbar; Texte und Anbieterangaben müssen vor Veröffentlichung rechtlich geprüft werden
- [#3 SwiftLint](https://github.com/Code-Noob82/EmigrateIn/issues/3): Build-Phase mit lokalem Installationshinweis
- [#4 VoiceOver](https://github.com/Code-Noob82/EmigrateIn/issues/4): Bezeichnungen und Hinweise für zentrale Anmelde-, Onboarding-, Profil- und Checklistenaktionen
- [#5 Darstellung](https://github.com/Code-Noob82/EmigrateIn/issues/5): adaptive Raster, skalierbare Onboarding-Grafik und konsistente Stilwerte

Die Issues werden nicht automatisch geschlossen. Dafür sind eine Prüfung im Zielprojekt und eine bewusste Veröffentlichung der Änderungen erforderlich.

## Rechtliche Grenze

Die eingebauten Datenschutz- und Nutzungsbedingungen sind Arbeitsfassungen. Für eine Veröffentlichung fehlen mindestens bestätigte Anbieter- und Kontaktdaten sowie eine rechtliche Prüfung der tatsächlich eingesetzten Dienste und Verarbeitungsabläufe.

## Bildschirmfotos

<p>
  <img src="./img/Screen1.png" width="200" alt="EmigrateIn Bildschirm 1">
  <img src="./img/Screen2.png" width="200" alt="EmigrateIn Bildschirm 2">
  <img src="./img/Screen3.png" width="200" alt="EmigrateIn Bildschirm 3">
  <img src="./img/Screen4.png" width="200" alt="EmigrateIn Bildschirm 4">
  <img src="./img/Screen5.png" width="200" alt="EmigrateIn Bildschirm 5">
  <img src="./img/Screen6.png" width="200" alt="EmigrateIn Bildschirm 6">
</p>
