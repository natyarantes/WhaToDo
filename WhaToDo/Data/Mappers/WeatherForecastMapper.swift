//
//  WeatherForecastMapper.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

nonisolated enum WeatherForecastMapper {
    static func map(_ dto: ForecastResponseDTO,
        city: City,
        fetchedAt: Date = Date()
    ) throws -> WeatherForecast {
        let daily = dto.daily

        let expectedCount = daily.time.count

        guard
            daily.weatherCode.count == expectedCount,
            daily.temperatureMax.count == expectedCount,
            daily.temperatureMin.count == expectedCount,
            daily.precipitationSum.count == expectedCount,
            daily.snowfallSum.count == expectedCount,
            daily.windSpeedMax.count == expectedCount
        else {
            throw AppError.invalidResponse
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        let days = try daily.time.indices.map { index in
            guard let date = formatter.date(
                from: daily.time[index]
            ) else {
                throw AppError.decodingFailed
            }

            return DailyWeather(
                date: date,
                minimumTemperature: daily.temperatureMin[index],
                maximumTemperature: daily.temperatureMax[index],
                precipitationSum: daily.precipitationSum[index],
                snowfallSum: daily.snowfallSum[index],
                maximumWindSpeed: daily.windSpeedMax[index],
                weatherCode: daily.weatherCode[index]
            )
        }

        guard !days.isEmpty else {
            throw AppError.noForecastAvailable
        }

        return WeatherForecast(
            city: city,
            days: days,
            fetchedAt: fetchedAt
        )
    }
}
