//
//  UserProfileRepositoryProtocol.swift
//  Expat App
//

import Foundation

protocol UserProfileRepositoryProtocol {
    func fetchGermanStates() async throws -> [StateSpecificInfo]
    func fetchProfile(userID: String) async throws -> UserProfile?
    func createInitialProfile(userID: String, email: String) async throws
    func updateHomeState(userID: String, stateID: String) async throws
    func updateDisplayName(userID: String, displayName: String) async throws
    func fetchStateDetails(stateID: String) async throws -> StateSpecificInfo?
    func deleteAllUserData(userID: String) async throws
}
