//
//  RecommendationsViewModelTests.swift
//  WhaToDo
//
//  Created by Natália Arantes on 10/08/26.
//

import Foundation
import Testing
@testable import WhaToDo

@MainActor
struct RecommendationsViewModelTests {
    @Test
    func successfulLoadPublishesForecastAndRecommendations() async {
        let forecast = makeForecast()
        let expectedRecommendations = makeRecommendations()

        let repository = WeatherRepositorySpy(
            responses: [.success(forecast)]
        )

        let rankingService = ActivityRankingStub(
            recommendations: expectedRecommendations
        )

        let viewModel = RecommendationsViewModel(
            city: forecast.city,
            weatherRepository: repository,
            rankingService: rankingService
        )

        await viewModel.load()

        #expect(viewModel.state.forecast == forecast)
        #expect(
            viewModel.state.recommend
                == expectedRecommendations
        )
        #expect(viewModel.state.hasContent)
        #expect(!viewModel.state.isLoading)
        #expect(viewModel.state.errorMessage == nil)

        let forceRefreshValues =
            await repository.receivedForceRefreshValues()

        #expect(forceRefreshValues == [false])
    }

    @Test
    func failedInitialLoadPublishesError() async {
        let city = makeCity()

        let repository = WeatherRepositorySpy(
            responses: [.failure(.networkUnavailable)]
        )

        let viewModel = RecommendationsViewModel(
            city: city,
            weatherRepository: repository,
            rankingService: ActivityRankingStub(
                recommendations: []
            )
        )

        await viewModel.load()

        #expect(viewModel.state.forecast == nil)
        #expect(viewModel.state.recommend.isEmpty)
        #expect(!viewModel.state.hasContent)
        #expect(!viewModel.state.isLoading)
        #expect(
            viewModel.state.errorMessage
                == AppError.networkUnavailable.localizedDescription
        )
    }

    @Test
    func refreshRequestsFreshForecast() async {
        let forecast = makeForecast()

        let repository = WeatherRepositorySpy(
            responses: [
                .success(forecast),
                .success(forecast)
            ]
        )

        let viewModel = RecommendationsViewModel(
            city: forecast.city,
            weatherRepository: repository,
            rankingService: ActivityRankingStub(
                recommendations: makeRecommendations()
            )
        )

        await viewModel.load()
        await viewModel.refresh()

        let forceRefreshValues =
            await repository.receivedForceRefreshValues()

        #expect(forceRefreshValues == [false, true])
        #expect(!viewModel.state.isRefreshing)
        #expect(viewModel.state.refreshErrorMessage == nil)
    }

    @Test
    func failedRefreshPreservesExistingContent() async {
        let forecast = makeForecast()
        let recommendations = makeRecommendations()

        let repository = WeatherRepositorySpy(
            responses: [
                .success(forecast),
                .failure(.networkUnavailable)
            ]
        )

        let viewModel = RecommendationsViewModel(
            city: forecast.city,
            weatherRepository: repository,
            rankingService: ActivityRankingStub(
                recommendations: recommendations
            )
        )

        await viewModel.load()
        await viewModel.refresh()

        #expect(viewModel.state.forecast == forecast)
        #expect(
            viewModel.state.recommend == recommendations
        )
        #expect(viewModel.state.hasContent)
        #expect(!viewModel.state.isRefreshing)
        #expect(
            viewModel.state.refreshErrorMessage
                == AppError.networkUnavailable.localizedDescription
        )
    }
}

private extension RecommendationsViewModelTests {
    func makeCity() -> City {
        City(
            id: 1,
            name: "Oslo",
            country: "Norway",
            adminArea: nil,
            latitude: 59.91,
            longitude: 10.75
        )
    }

    func makeForecast() -> WeatherForecast {
        let city = makeCity()

        let day = DailyWeather(
            date: Date(timeIntervalSince1970: 0),
            minimumTemperature: -5,
            maximumTemperature: 1,
            precipitationSum: 0,
            snowfallSum: 5,
            maximumWindSpeed: 15,
            weatherCode: 71
        )

        return WeatherForecast(
            city: city,
            days: [day],
            fetchedAt: Date(timeIntervalSince1970: 100)
        )
    }

    func makeRecommendations() -> [ActivityRecommend] {
        [
            ActivityRecommend(
                activity: .skiing,
                score: 90,
                reasons: ["Snow is expected."]
            ),
            ActivityRecommend(
                activity: .indoorSightseeing,
                score: 40,
                reasons: ["Weather-independent option."]
            )
        ]
    }
}

private actor WeatherRepositorySpy: WeatherRepository {
    enum Response: Sendable {
        case success(WeatherForecast)
        case failure(AppError)
    }

    private var responses: [Response]
    private var forceRefreshValues: [Bool] = []

    init(responses: [Response]) {
        self.responses = responses
    }

    func fetchForecast(
        for city: City,
        forceRefresh: Bool
    ) async throws -> ForecastResult {
        forceRefreshValues.append(forceRefresh)

        guard !responses.isEmpty else {
            throw AppError.unknown
        }

        let response = responses.removeFirst()

        switch response {
        case .success(let forecast):
            return ForecastResult(forecast: forecast)

        case .failure(let error):
            throw error
        }
    }

    func receivedForceRefreshValues() -> [Bool] {
        forceRefreshValues
    }
}

private struct ActivityRankingStub:
    ActivityRankingService {

    let recommendations: [ActivityRecommend]

    func rankActivities(
        for forecast: WeatherForecast
    ) -> [ActivityRecommend] {
        recommendations
    }
}
