//
//  RecommendationsViewModel.swift.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RecommendationsViewModel {
    
    private(set) var state = RecommendationsViewState.initial

    let city: City

    private let weatherRepository: WeatherRepository
    private let rankingService: ActivityRankingService

    init(
        city: City,
        weatherRepository: WeatherRepository,
        rankingService: ActivityRankingService
    ) {
        self.city = city
        self.weatherRepository = weatherRepository
        self.rankingService = rankingService
    }

    func load() async {
        guard !state.isLoading else {
            return
        }

        state.isLoading = true
        state.errorMessage = nil

        defer {
            state.isLoading = false
        }

        do {
            let result = try await weatherRepository.fetchForecast(
                for: city,
                forceRefresh: false
            )

            apply(result)
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        guard !state.isRefreshing else {
            return
        }

        state.isRefreshing = true
        state.refreshErrorMessage = nil

        defer {
            state.isRefreshing = false
        }

        do {
            let result = try await weatherRepository.fetchForecast(
                for: city,
                forceRefresh: true
            )

            apply(result)
        } catch {
            state.refreshErrorMessage = error.localizedDescription
        }
    }

    private func apply(_ result: ForecastResult) {
        state.forecast = result.forecast
        state.recommend = rankingService.rankActivities(
            for: result.forecast
        )
        state.errorMessage = nil
    }
}
