//
//  ContentRepository.swift
//  Expat App
//

import FirebaseFirestore
import Foundation

final class ContentRepository: ContentRepositoryProtocol {
    private let database = Firestore.firestore()

    func fetchInfoCategories() async throws -> [InfoCategory] {
        let snapshot = try await database.collection("info_categories")
            .order(by: "order")
            .getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: InfoCategory.self)
        }
    }

    func fetchInfoContent(for categoryId: String) async throws -> [InfoContent] {
        let snapshot = try await database.collection("info_content")
            .whereField("categoryId", isEqualTo: categoryId)
            .order(by: "order")
            .getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: InfoContent.self)
        }
    }

    func fetchChecklistCategories() async throws -> [ChecklistCategory] {
        let snapshot = try await database.collection("checklist_categories")
            .order(by: "order")
            .getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: ChecklistCategory.self)
        }
    }

    func fetchChecklistCategory(by id: String) async throws -> ChecklistCategory? {
        let snapshot = try await database.collection("checklist_categories")
            .document(id)
            .getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: ChecklistCategory.self)
    }

    func fetchChecklistItems(for categoryId: String) async throws -> [ChecklistItem] {
        let snapshot = try await database.collection("checklist_items")
            .whereField("categoryId", isEqualTo: categoryId)
            .order(by: "order")
            .getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: ChecklistItem.self)
        }
    }

    func setItemCompletionStatusInSubcollection(
        userId: String,
        itemId: String,
        isCompleted: Bool
    ) async throws {
        let itemReference = database.collection("user_checklist_states")
            .document(userId)
            .collection("completed_items")
            .document(itemId)

        if isCompleted {
            try await itemReference.setData(["markedAt": FieldValue.serverTimestamp()])
        } else {
            try await itemReference.delete()
        }
    }

    func addCompletedItemsSubcollectionListener(
        for userId: String,
        completion: @escaping (Result<Set<String>, Error>) -> Void
    ) -> ListenerRegistration {
        database.collection("user_checklist_states")
            .document(userId)
            .collection("completed_items")
            .addSnapshotListener { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }

                let completedItemIDs = Set(snapshot?.documents.map(\.documentID) ?? [])
                completion(.success(completedItemIDs))
            }
    }
}
