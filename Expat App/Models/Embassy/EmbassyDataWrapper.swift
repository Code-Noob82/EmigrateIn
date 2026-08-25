//
//  Ebassy.swift
//  Expat App
//
//  Created by Dominik Baki on 12.05.25.
//

import Foundation

// MARK: - Data Models für Auswärtiges Amt API

// 1. Top-Level-Struktur der API-Antwort
struct EmbassyDataWrapper: Decodable {
    let response: EmbassyResponseData
}

// 2. Inhalt des "response"-Objekts
struct EmbassyResponseData: Decodable {
    let lastModified: Int
    let countryGroups: [String: EmbassyCountryGroup]
    
    private enum StaticCodingKeys: String, CodingKey {
        case lastModified, contentList
    }
    
    private struct DynamicCountryCodingKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }
    init(from decoder: Decoder) throws {
        let staticContainer = try decoder.container(keyedBy: StaticCodingKeys.self)
        self.lastModified = try staticContainer.decode(Int.self, forKey: .lastModified)

        let dynamicContainer = try decoder.container(keyedBy: DynamicCountryCodingKey.self)
        let listedGroupIDs = try staticContainer.decodeIfPresent([String].self, forKey: .contentList)
        let groupIDs = listedGroupIDs ?? dynamicContainer.allKeys
            .map(\.stringValue)
            .filter { Int($0) != nil }
        var groups = [String: EmbassyCountryGroup]()
        for groupID in groupIDs {
            guard let countryKey = DynamicCountryCodingKey(stringValue: groupID) else { continue }
            groups[groupID] = try dynamicContainer.decode(EmbassyCountryGroup.self, forKey: countryKey)
        }
        self.countryGroups = groups
    }
}

// 3. Struktur für eine Ländergruppe (z.B. Zypern mit ID "210268")
struct EmbassyCountryGroup: Decodable {
    let lastModified: Int
    let country: String
    let representatives: [String: EmbassyRepresentativeInfo]
    let contentList: [String]
    
    private enum StaticCodingKeys: String, CodingKey {
        case lastModified, country, contentList
    }
    
    private struct DynamicRepresentativeCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int?
        init?(intValue: Int) { return nil }
    }
    init(from decoder: Decoder) throws {
        let staticContainer = try decoder.container(keyedBy: StaticCodingKeys.self)
        self.lastModified = try staticContainer.decode(Int.self, forKey: .lastModified)
        self.country = try staticContainer.decode(String.self, forKey: .country)
        let listedRepresentativeIDs = try staticContainer.decodeIfPresent([String].self, forKey: .contentList)
        self.contentList = listedRepresentativeIDs ?? []

        let dynamicContainer = try decoder.container(keyedBy: DynamicRepresentativeCodingKeys.self)
        let representativeIDs = listedRepresentativeIDs ?? dynamicContainer.allKeys
            .map(\.stringValue)
            .filter { Int($0) != nil }
        var reps = [String: EmbassyRepresentativeInfo]()
        for representativeID in representativeIDs {
            guard let representativeKey = DynamicRepresentativeCodingKeys(stringValue: representativeID) else { continue }
            reps[representativeID] = try dynamicContainer.decode(
                EmbassyRepresentativeInfo.self,
                forKey: representativeKey
            )
        }
        self.representatives = reps
    }
}

// 4. Struktur für die Details einer einzelnen Vertretung
struct EmbassyRepresentativeInfo: Decodable, Hashable {
    let lastModified: Int
    let description: String?
    let leader: String?
    let city: String?
    let country: String?
    let address: String?
    let phone: String?
    let email: String?
    let website: [String?]?
    let open: String?
    let remark: String?
    let emergencyPhone: String?
    let contact: String?
    let misc: String?
    let departments: String?
    let locales: String?
    let fax: String?
    let postal: String?
    let county: String?
    
    enum CodingKeys: String, CodingKey {
        case lastModified, description, leader, city, country, address, phone, website, open, remark, emergencyPhone, contact, misc, departments, locales, fax, postal, county
        case email = "mail"
    }
}
