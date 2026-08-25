//
//  InfoCategoryViewModel.swift
//  Expat App
//
//  Created by Dominik Baki on 05.05.25.
//

import Foundation
import SwiftUI

@MainActor
class InfoCategoryViewModel: ObservableObject {
    @Published var categories: [InfoCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ContentRepositoryProtocol
    
    init(repository: ContentRepositoryProtocol = ContentRepository()) {
        self.repository = repository
    }
    
    func fetchCategories() async {
        guard !isLoading else { return }
        guard categories.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            self.categories = try await repository.fetchInfoCategories()
        } catch {
            self.errorMessage = "Fehler beim Laden der Kategorien: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
