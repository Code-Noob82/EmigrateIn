//
//  ChecklistCategoryViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 21.05.25.
//

import Foundation
import SwiftUI
import FirebaseFirestore


@MainActor // Stellt sicher, dass UI-Updates auf dem Hauptthread passieren
class ChecklistCategoryViewModel: ObservableObject {
    @Published var categories: [ChecklistCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let repository: ContentRepositoryProtocol // Abhängigkeit von ContentRepositoryProtocol

    // Dependency Injection: Standard-Initialisierer verwendet ContentRepository
    init(repository: ContentRepositoryProtocol = ContentRepository()) {
        self.repository = repository
        // Optional: Hier fetchCategories() aufrufen, wenn Kategorien sofort geladen werden sollen,
        // z.B. wenn die View, die dieses ViewModel nutzt, erscheint.
        // Task { await fetchCategories() }
    }

    // Funktion zum Abrufen der Checklisten-Kategorien
    func fetchCategories() async {
        guard !isLoading else { return } // Verhindert mehrfaches Laden

        isLoading = true
        errorMessage = nil

        do {
            let fetchedCategories = try await repository.fetchChecklistCategories() // Ruft die Repository-Funktion auf
            self.categories = fetchedCategories
        } catch {
            self.errorMessage = "Fehler beim Laden der Checklisten-Kategorien: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
