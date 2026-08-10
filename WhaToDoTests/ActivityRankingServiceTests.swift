//
//  WhaToDoTests.swift
//  WhaToDoTests
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation
import Testing
@testable import WhaToDo

struct ActivityRankingServiceTests {
    private let service = DefaultActivityRankingService()

    @Test
    func snowyAndColdForecastRanksSkiingFirst() {
        let forecast = makeForecast(
            minimumTemperature: -6,
            maximumTemperature: 0,
            precipitation: 0,
            snowfall: 4,
            windSpeed: 15
        )

        let recommendations = service.rankActivities(
            for: forecast
        )

        #expect(recommendations.count == 4)
        #expect(recommendations.first?.activity == .skiing)
        #expect(recommendations.first?.score == 100)
    }

    @Test
    func mildAndDryForecastRanksOutdoorSightseeingFirst() {
        let forecast = makeForecast(
            minimumTemperature: 18,
            maximumTemperature: 24,
            precipitation: 0,
            snowfall: 0,
            windSpeed: 12
        )

        let recommendations = service.rankActivities(
            for: forecast
        )

        #expect(
            recommendations.first?.activity
                == .outdoorSightseeing
        )
    }

    @Test
    func extremeWeatherRanksIndoorSightseeingFirst() {
        let forecast = makeForecast(
            minimumTemperature: 34,
            maximumTemperature: 40,
            precipitation: 8,
            snowfall: 0,
            windSpeed: 45
        )

        let recommendations = service.rankActivities(
            for: forecast
        )

        #expect(
            recommendations.first?.activity
                == .indoorSightseeing
        )
    }

    @Test
    func emptyForecastReturnsNoRecommendations() {
        let forecast = WeatherForecast(
            city: makeCity(),
            days: [],
            fetchedAt: Date()
        )

        let recommendations = service.rankActivities(
            for: forecast
        )

        #expect(recommendations.isEmpty)
    }

    @Test
    func recommendationsAreSortedAndScoresStayBetweenZeroAndOneHundred() {
        let forecast = makeForecast(
            minimumTemperature: 10,
            maximumTemperature: 20,
            precipitation: 3,
            snowfall: 0,
            windSpeed: 25
        )

        let recommendations = service.rankActivities(
            for: forecast
        )

        #expect(
            recommendations.allSatisfy {
                (0...100).contains($0.score)
            }
        )

        let scores = recommendations.map(\.score)

        #expect(scores == scores.sorted(by: >))
    }
}

private extension ActivityRankingServiceTests {
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

    func makeForecast(
        minimumTemperature: Double,
        maximumTemperature: Double,
        precipitation: Double,
        snowfall: Double,
        windSpeed: Double
    ) -> WeatherForecast {
        let calendar = Calendar(identifier: .gregorian)
        let initialDate = Date(timeIntervalSince1970: 0)

        let days = (0..<7).map { offset in
            DailyWeather(
                date: calendar.date(
                    byAdding: .day,
                    value: offset,
                    to: initialDate
                )!,
                minimumTemperature: minimumTemperature,
                maximumTemperature: maximumTemperature,
                precipitationSum: precipitation,
                snowfallSum: snowfall,
                maximumWindSpeed: windSpeed,
                weatherCode: 0
            )
        }

        return WeatherForecast(
            city: makeCity(),
            days: days,
            fetchedAt: initialDate
        )
    }
}
