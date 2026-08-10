//
//  WeatherForecastMapperTests.swift
//  WhaToDo
//
//  Created by Natália Arantes on 10/08/26.
//

import Foundation
import Testing
@testable import WhaToDo

struct WeatherForecastMapperTests {
    @Test
    func validDTOIsMappedToWeatherForecast() throws {
        let city = makeCity()
        let fetchedAt = Date(timeIntervalSince1970: 100)

        let dto = ForecastResponseDTO(
            daily: DailyForecastDTO(
                time: ["2026-08-10", "2026-08-11"],
                weatherCode: [1, 61],
                temperatureMax: [25, 22],
                temperatureMin: [15, 14],
                precipitationSum: [0, 5],
                snowfallSum: [0, 0],
                windSpeedMax: [12, 18]
            )
        )

        let forecast = try WeatherForecastMapper.map(
            dto,
            city: city,
            fetchedAt: fetchedAt
        )

        #expect(forecast.city == city)
        #expect(forecast.fetchedAt == fetchedAt)
        #expect(forecast.days.count == 2)

        let firstDay = try #require(forecast.days.first)

        #expect(firstDay.weatherCode == 1)
        #expect(firstDay.maximumTemperature == 25)
        #expect(firstDay.minimumTemperature == 15)
        #expect(firstDay.precipitationSum == 0)
        #expect(firstDay.snowfallSum == 0)
        #expect(firstDay.maximumWindSpeed == 12)
    }

    @Test
    func arraysWithDifferentSizesThrowInvalidResponse() {
        let dto = ForecastResponseDTO(
            daily: DailyForecastDTO(
                time: ["2026-08-10", "2026-08-11"],
                weatherCode: [1],
                temperatureMax: [25, 22],
                temperatureMin: [15, 14],
                precipitationSum: [0, 5],
                snowfallSum: [0, 0],
                windSpeedMax: [12, 18]
            )
        )

        do {
            _ = try WeatherForecastMapper.map(
                dto,
                city: makeCity()
            )

            Issue.record(
                "Expected AppError.invalidResponse"
            )
        } catch {
            #expect(error as? AppError == .invalidResponse)
        }
    }

    @Test
    func invalidDateThrowsDecodingFailed() {
        let dto = ForecastResponseDTO(
            daily: DailyForecastDTO(
                time: ["invalid-date"],
                weatherCode: [1],
                temperatureMax: [25],
                temperatureMin: [15],
                precipitationSum: [0],
                snowfallSum: [0],
                windSpeedMax: [12]
            )
        )

        do {
            _ = try WeatherForecastMapper.map(
                dto,
                city: makeCity()
            )

            Issue.record(
                "Expected AppError.decodingFailed"
            )
        } catch {
            #expect(error as? AppError == .decodingFailed)
        }
    }

    @Test
    func emptyForecastThrowsNoForecastAvailable() {
        let dto = ForecastResponseDTO(
            daily: DailyForecastDTO(
                time: [],
                weatherCode: [],
                temperatureMax: [],
                temperatureMin: [],
                precipitationSum: [],
                snowfallSum: [],
                windSpeedMax: []
            )
        )

        do {
            _ = try WeatherForecastMapper.map(
                dto,
                city: makeCity()
            )

            Issue.record(
                "Expected AppError.noForecastAvailable"
            )
        } catch {
            #expect(
                error as? AppError == .noForecastAvailable
            )
        }
    }
}

private extension WeatherForecastMapperTests {
    func makeCity() -> City {
        City(
            id: 1,
            name: "São Paulo",
            country: "Brazil",
            adminArea: "São Paulo",
            latitude: -23.5505,
            longitude: -46.6333
        )
    }
}
