//
//  CitySearchViewModel.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation
import Observation

@Observable
final class CitySearchViewModel {
    var query = ""
    private(set) var state: CitySearchState = .idle

    private let cityRepository: CityRepositories

    init(cityRepository: CityRepositories) {
        self.cityRepository = cityRepository
    }

    func search() async {
        let trimmedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedQuery.isEmpty else {
            state = .error(
                AppError.invalidSearchQuery.localizedDescription
            )
            return
        }

        state = .loading

        do {
            let cities = try await cityRepository.getCity(
                query: trimmedQuery
            )

            if cities.isEmpty {
                state = .empty
            } else {
                state = .results(cities)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func clearSearch() {
        query = ""
        state = .idle
    }
}
