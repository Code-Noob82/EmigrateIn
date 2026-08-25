//
//  ChecklistViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import Foundation
import FirebaseFirestore // Für Firestore-Typen wie DocumentID etc.
import FirebaseAuth // Um die aktuelle UserID zu bekommen

@MainActor
class ChecklistViewModel: ObservableObject {
    @Published var items: [ChecklistItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    @Published var categoryDescription: String? = nil
    @Published var categoryTitle: String? = nil
    
    // Zustand der Items für den aktuellen Nutzer: [ChecklistItem.id : isCompleted (Bool)]
    @Published var completedItemIDs: Set<String> = []
    @Published private(set) var currentUserId: String?
    @Published var isCurrentuserAnonymous = false
    
    // MARK: - NEU: Fortschritts-Eigenschaften
    @Published var totalProgress: Double = 0.0 // Gesamtfortschritt (0.0 - 1.0)
    @Published var totalCompletedItems: Int = 0
    @Published var totalItems: Int = 0
    
    private let categoryId: String // Die Kategorie-ID für diese Checkliste
    private let repository: ContentRepositoryProtocol // Abhängigkeit vom Protokoll
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // NEU: Firestore Snapshot Listener Handle
    private var checklistStateListener: ListenerRegistration?
    
    
    // Dependency Injection: Initialisiert mit categoryId und optionalem Repository
    init(categoryId: String, repository: ContentRepositoryProtocol = ContentRepository()) {
        self.categoryId = categoryId
        self.repository = repository
        self.currentUserId = Auth.auth().currentUser?.uid
        self.isCurrentuserAnonymous = Auth.auth().currentUser?.isAnonymous ?? true // Default true, falls kein Nutzer
        
        // Listener für den Anmeldestatus, um user_checklist_states zu laden/speichern
        addAuthListener()
        
        // Initiales Laden der Checklisten-Items und des Status
        Task {
            await fetchChecklistItemsAndCategoryDetails() // Lädt die Items der Kategorie
            // Der Listener für den Status wird jetzt im AuthListener oder bei Bedarf aufgerufen
            // und heißt jetzt z.B. listenForCompletedItemIDs
            if let _ = self.currentUserId, !self.isCurrentuserAnonymous {
                await listenForCompletedItemIDs() // GEÄNDERT: Ruft die neue Listener-Funktion auf
            } else {
                self.removeChecklistStateListener()
                self.completedItemIDs = [] // GEÄNDERT: Leert das Set
                self.calculateOverallProgress() // Fortschritt neu berechnen
            }
        }
    }
    
    deinit {
        // Auth-Listener beim Deinitialisieren entfernen, um Speicherlecks zu vermeiden
        if let handle = authListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        Task { @MainActor [weak self] in
            self?.removeChecklistStateListener()
        }
    }
    
    // MARK: - Daten laden (Kategorie-Details, Items & Status)
    
    func fetchChecklistItemsAndCategoryDetails() async {
        guard !isLoading else {
            return // Verhindert mehrfaches Laden
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Kategorie-Details laden (für die Beschreibung)
            if let category = try await repository.fetchChecklistCategory(by: self.categoryId) {
                self.categoryDescription = category.description
                self.categoryTitle = category.title
            } else {
                self.categoryDescription = nil
                self.categoryTitle = nil
            }
            
            // 2. Checklisten-Items laden
            let fetchedItems = try await repository.fetchChecklistItems(for: self.categoryId)
            self.items = fetchedItems.sorted(by: { $0.order < $1.order })
            self.totalItems = self.items.count
            
            self.calculateOverallProgress()
            
        } catch {
            self.errorMessage = "Fehler beim Laden der Checkliste: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    // MARK: - Listener für erledigte Item-IDs (NEUE FUNKTION)
    func listenForCompletedItemIDs() async { // Neuer Name und Logik
        guard let userId = self.currentUserId, !isCurrentuserAnonymous else {
            self.completedItemIDs = []
            self.calculateOverallProgress()
            removeChecklistStateListener()
            return
        }
        
        removeChecklistStateListener() // Alten Listener entfernen, falls vorhanden
        
        checklistStateListener = repository.addCompletedItemsSubcollectionListener(for: userId) { [weak self] result in
            guard let self = self else { return }
            
            Task { @MainActor in // Explizit auf MainActor für UI-relevante Updates
                switch result {
                case .success(let fetchedItemIDs):
                    self.completedItemIDs = fetchedItemIDs
                    self.calculateOverallProgress() // Fortschritt aktualisieren, da sich die erledigten Items geändert haben
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden des Status: \(error.localizedDescription)"
                    self.completedItemIDs = [] // Bei Fehler leeren
                    self.calculateOverallProgress() // Fortschritt aktualisieren
                }
            }
        }
    }
    
    // Funktion zum Entfernen des Listeners
    private func removeChecklistStateListener() {
        if let listener = checklistStateListener {
            listener.remove()
            checklistStateListener = nil
        }
    }
    
    // MARK: - Status von Checklist-Items verwalten (ANGEPASST)
    
    func toggleItemCompletion(item: ChecklistItem) async {
        guard let userId = self.currentUserId, !isCurrentuserAnonymous, let itemId = item.id else {
            errorMessage = "Anmeldung erforderlich oder Item hat keine ID."
            return
        }
        
        let isCurrentlyCompleted = completedItemIDs.contains(itemId)
        let newCompletionStatus = !isCurrentlyCompleted
        
        // Optimistisches UI-Update
        if newCompletionStatus {
            completedItemIDs.insert(itemId)
        } else {
            completedItemIDs.remove(itemId)
        }
        self.calculateOverallProgress() // Fortschritt nach lokaler Änderung aktualisieren
        
        do {
            // Rufe die neue Repository-Funktion auf
            try await repository.setItemCompletionStatusInSubcollection(userId: userId, itemId: itemId, isCompleted: newCompletionStatus)
            // Der Listener wird den State von Firestore holen und ggf. korrigieren (obwohl es bei dieser Methode meist konsistent sein sollte)
        } catch {
            self.errorMessage = "Fehler beim Speichern des Status: \(error.localizedDescription)"
            // Optimistisches Update zurückrollen bei Fehler
            if newCompletionStatus {
                completedItemIDs.remove(itemId)
            } else {
                completedItemIDs.insert(itemId)
            }
            self.calculateOverallProgress() // Fortschritt nach Rollback aktualisieren
        }
    }
    
    // MARK: - Fortschrittsberechnung (ANGEPASST)
    private func calculateOverallProgress() {
        guard totalItems > 0 else {
            totalProgress = 0.0
            self.totalCompletedItems = 0 // Stellt sicher, dass auch dies zurückgesetzt wird
            return
        }
        
        // Zählt, wie viele der Items der aktuellen Kategorie in der Menge der erledigten IDs sind
        let relevantCompletedCount = self.items.filter { checklistItem in
            guard let checklistItemId = checklistItem.id else { return false }
            return self.completedItemIDs.contains(checklistItemId)
        }.count
        
        self.totalCompletedItems = relevantCompletedCount
        totalProgress = Double(relevantCompletedCount) / Double(totalItems)
    }
    
    // Hilfsfunktion, um zu prüfen, ob ein Item erledigt ist (ANGEPASST)
    func isItemCompleted(_ item: ChecklistItem) -> Bool {
        guard let itemId = item.id else {
            return false
        }
        let isCompleted = completedItemIDs.contains(itemId)
        return isCompleted
    }
    
    
    // MARK: - Auth State Listener (ANGEPASST, um neue Listener-Funktion aufzurufen)
    private func addAuthListener() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            Task { @MainActor in
                let newUserId = user?.uid
                let newIsAnonymous = user?.isAnonymous ?? true // Default true, falls kein Nutzer mehr da (abgemeldet)
                
                // Reagiere nur, wenn sich die UserID oder der Anonymitätsstatus tatsächlich geändert hat
                if newUserId != self.currentUserId || newIsAnonymous != self.isCurrentuserAnonymous {
                    self.currentUserId = newUserId
                    self.isCurrentuserAnonymous = newIsAnonymous
                    
                    if newUserId != nil && !newIsAnonymous {
                        // Nutzer ist angemeldet und nicht anonym
                        await self.listenForCompletedItemIDs() // NEU: Ruft die korrekte Listener-Funktion auf
                    } else {
                        // Nutzer abgemeldet oder anonym
                        self.removeChecklistStateListener()
                        self.completedItemIDs = [] // GEÄNDERT: Leert das Set
                        self.calculateOverallProgress() // Fortschritt neu berechnen
                    }
                }
            }
        }
    }
}
