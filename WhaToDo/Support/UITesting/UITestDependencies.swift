//
//  UITestDependencies.swift
//  WhaToDo
//
//  Created by Natália Arantes on 10/08/26.
//

import Foundation

struct UITestCityRepository: CityRepositories {
    func getCity(query: String) async throws -> [City] {
        let arguments =
            ProcessInfo.processInfo.arguments

        if arguments.contains("-ui-testing-empty") {
            return []
        }

        if arguments.contains("-ui-testing-search-error") {
            throw AppError.networkUnavailable
        }

        return [
            City(
                id: 1,
                name: "Oslo",
                country: "Norway",
                adminArea: "Oslo",
                latitude: 59.91,
                longitude: 10.75
            )
        ]
    }
}

struct UITestWeatherRepository: WeatherRepository {
    func fetchForecast(
        for city: City,
        forceRefresh: Bool
    ) async throws -> ForecastResult {
        let calendar = Calendar(
            identifier: .gregorian
        )

        let initialDate = Date(
            timeIntervalSince1970: 0
        )

        let days = (0..<7).map { offset in
            DailyWeather(
                date: calendar.date(
                    byAdding: .day,
                    value: offset,
                    to: initialDate
                )!,
                minimumTemperature: -6,
                maximumTemperature: 0,
                precipitationSum: 0,
                snowfallSum: 4,
                maximumWindSpeed: 15,
                weatherCode: 71
            )
        }

        let forecast = WeatherForecast(
            city: city,
            days: days,
            fetchedAt: initialDate
        )

        return ForecastResult(forecast: forecast)
    }
}
