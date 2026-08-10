//
//  DefaultCityRepository.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct DefaultCityRepository: CityRepositories {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getCity(query: String) async throws -> [City] {
        guard var components = URLComponents(
            string: "https://geocoding-api.open-meteo.com/v1/search"
        ) else {
            throw AppError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(
                name: "name",
                value: query
            ),
            URLQueryItem(
                name: "count",
                value: "10"
            ),
            URLQueryItem(
                name: "language",
                value: "en"
            ),
            URLQueryItem(
                name: "format",
                value: "json"
            )
        ]

        guard let url = components.url else {
            throw AppError.invalidURL
        }

        let response = try await apiClient.request(url, responseType: GeocodingResponseDTO.self)

        return (response.results ?? []).map(CityMapper.map)
    }
}
