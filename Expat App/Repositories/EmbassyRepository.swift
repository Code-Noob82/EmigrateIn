//
//  EmbassyRepository.swift
//  Expat App
//

import Foundation

final class EmbassyRepository: EmbassyRepositoryProtocol {
    private let apiURL = "https://www.auswaertiges-amt.de/opendata/representativesInCountry"

    func fetchGermanEmbassy(forCountryName targetCountryName: String) async throws -> Embassy? {
        let data = try await fetchData()
        guard let group = matchingGroup(named: targetCountryName, in: data) else { return nil }

        guard let entry = group.representatives.first(where: { _, information in
            guard let description = information.description?.lowercased() else { return false }
            return description.contains("botschaft") || description.contains("embassy")
        }) else {
            return nil
        }

        return makeEmbassy(id: entry.key, information: entry.value)
    }

    func fetchAllRepresentationsInCountry(countryName: String) async throws -> [Embassy] {
        let data = try await fetchData()
        guard let group = matchingGroup(named: countryName, in: data) else { return [] }

        return group.representatives
            .map { makeEmbassy(id: $0.key, information: $0.value) }
            .sorted { ($0.city ?? "").localizedCaseInsensitiveCompare($1.city ?? "") == .orderedAscending }
    }

    func fetchAllCountryNames() async throws -> [String] {
        let data = try await fetchData()
        return Array(Set(data.response.countryGroups.values.map(\.country))).sorted()
    }

    private func fetchData() async throws -> EmbassyDataWrapper {
        guard let url = URL(string: apiURL) else {
            throw ApiError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                throw ApiError.invalidResponse
            }
            return try JSONDecoder().decode(EmbassyDataWrapper.self, from: data)
        } catch let error as ApiError {
            throw error
        } catch let error as DecodingError {
            throw ApiError.decodingError(error)
        } catch {
            throw ApiError.networkError(error)
        }
    }

    private func matchingGroup(
        named countryName: String,
        in data: EmbassyDataWrapper
    ) -> EmbassyCountryGroup? {
        data.response.countryGroups.values.first {
            $0.country.localizedCaseInsensitiveContains(countryName)
        }
    }

    private func makeEmbassy(
        id: String,
        information: EmbassyRepresentativeInfo
    ) -> Embassy {
        Embassy(
            id: id,
            type: information.description,
            countryName: information.country,
            city: information.city,
            address: information.address,
            phone: information.phone,
            email: information.email,
            url: information.website?.compactMap { $0 }.first,
            openingHours: information.open,
            remark: information.remark
        )
    }
}
