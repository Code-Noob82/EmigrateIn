//
//  UserProfileRepository.swift
//  Expat App
//

import FirebaseFirestore
import Foundation

final class UserProfileRepository: UserProfileRepositoryProtocol {
    private let configuredDatabase: Firestore?

    private var database: Firestore {
        configuredDatabase ?? Firestore.firestore()
    }

    init(database: Firestore? = nil) {
        self.configuredDatabase = database
    }

    func fetchGermanStates() async throws -> [StateSpecificInfo] {
        let snapshot = try await database.collection("state_specific_info")
            .order(by: "order")
            .getDocuments()
        return try snapshot.documents.map { try $0.data(as: StateSpecificInfo.self) }
    }

    func fetchProfile(userID: String) async throws -> UserProfile? {
        let snapshot = try await database.collection("user_profiles")
            .document(userID)
            .getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: UserProfile.self)
    }

    func createInitialProfile(userID: String, email: String) async throws {
        try await database.collection("user_profiles")
            .document(userID)
            .setData(
                [
                    "email": email,
                    "createdAt": Timestamp(date: Date()),
                    "homeStateId": ""
                ],
                merge: true
            )
    }

    func updateHomeState(userID: String, stateID: String) async throws {
        try await database.collection("user_profiles")
            .document(userID)
            .updateData(["homeStateId": stateID])
    }

    func updateDisplayName(userID: String, displayName: String) async throws {
        try await database.collection("user_profiles")
            .document(userID)
            .updateData(["displayName": displayName])
    }

    func fetchStateDetails(stateID: String) async throws -> StateSpecificInfo? {
        let snapshot = try await database.collection("state_specific_info")
            .document(stateID)
            .getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: StateSpecificInfo.self)
    }

    func deleteAllUserData(userID: String) async throws {
        let userChecklistDocument = database.collection("user_checklist_states").document(userID)
        let completedItems = try await userChecklistDocument
            .collection("completed_items")
            .getDocuments()

        for document in completedItems.documents {
            try await document.reference.delete()
        }

        try await userChecklistDocument.delete()
        try await database.collection("user_profiles").document(userID).delete()
    }
}
