//
//  DefaultWeatherRepository.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct DefaultWeatherRepository: WeatherRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchForecast(for city: City, forceRefresh: Bool) async throws -> ForecastResult {
        guard var components = URLComponents(
            string: "https://api.open-meteo.com/v1/forecast"
        ) else {
            throw AppError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(
                name: "latitude",
                value: String(city.latitude)
            ),
            URLQueryItem(
                name: "longitude",
                value: String(city.longitude)
            ),
            URLQueryItem(
                name: "daily",
                value: [
                    "weather_code",
                    "temperature_2m_max",
                    "temperature_2m_min",
                    "precipitation_sum",
                    "snowfall_sum",
                    "wind_speed_10m_max"
                ].joined(separator: ",")
            ),
            URLQueryItem(
                name: "forecast_days",
                value: "7"
            ),
            URLQueryItem(
                name: "timezone",
                value: "auto"
            )
        ]

        guard let url = components.url else {
            throw AppError.invalidURL
        }

        let response = try await apiClient.request(url, responseType: ForecastResponseDTO.self)

        let forecast = try WeatherForecastMapper.map(response,city: city)

        return ForecastResult(forecast: forecast)
    }
}
