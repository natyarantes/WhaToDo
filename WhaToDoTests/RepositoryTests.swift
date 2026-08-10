//
//  RepositoryTests.swift
//  WhaToDo
//
//  Created by Natália Arantes on 10/08/26.
//

import Foundation
import Testing
@testable import WhaToDo

@MainActor
struct RepositoryTests {
    @Test
    func cityRepositoryBuildsURLAndMapsCities() async throws {
        let json = """
        {
          "results": [
            {
              "id": 2643743,
              "name": "London",
              "latitude": 51.5072,
              "longitude": -0.1276,
              "country": "United Kingdom",
              "admin1": "England"
            }
          ]
        }
        """

        let apiClient = APIClientSpy(
            responseData: Data(json.utf8)
        )

        let repository = DefaultCityRepository(
            apiClient: apiClient
        )

        let cities = try await repository.getCity(
            query: "London"
        )

        let city = try #require(cities.first)

        #expect(city.id == 2_643_743)
        #expect(city.name == "London")
        #expect(city.country == "United Kingdom")
        #expect(city.adminArea == "England")
        #expect(city.latitude == 51.5072)
        #expect(city.longitude == -0.1276)

        let requestedURL = try #require(
            await apiClient.lastRequestedURL()
        )

        #expect(
            requestedURL.host
                == "geocoding-api.open-meteo.com"
        )
        #expect(requestedURL.path == "/v1/search")

        let parameters = queryParameters(
            from: requestedURL
        )

        #expect(parameters["name"] == "London")
        #expect(parameters["count"] == "10")
        #expect(parameters["language"] == "en")
        #expect(parameters["format"] == "json")
    }

    @Test
    func weatherRepositoryBuildsURLAndMapsForecast() async throws {
        let json = """
        {
          "daily": {
            "time": ["2026-08-10"],
            "weather_code": [1],
            "temperature_2m_max": [24.5],
            "temperature_2m_min": [15.0],
            "precipitation_sum": [2.5],
            "snowfall_sum": [0.0],
            "wind_speed_10m_max": [18.0]
          }
        }
        """

        let apiClient = APIClientSpy(
            responseData: Data(json.utf8)
        )

        let repository = DefaultWeatherRepository(
            apiClient: apiClient
        )

        let city = makeCity()

        let result = try await repository.fetchForecast(
            for: city,
            forceRefresh: false
        )

        #expect(result.forecast.city == city)
        #expect(result.forecast.days.count == 1)

        let day = try #require(
            result.forecast.days.first
        )

        #expect(day.weatherCode == 1)
        #expect(day.maximumTemperature == 24.5)
        #expect(day.minimumTemperature == 15)
        #expect(day.precipitationSum == 2.5)
        #expect(day.snowfallSum == 0)
        #expect(day.maximumWindSpeed == 18)

        let requestedURL = try #require(
            await apiClient.lastRequestedURL()
        )

        #expect(
            requestedURL.host == "api.open-meteo.com"
        )
        #expect(requestedURL.path == "/v1/forecast")

        let parameters = queryParameters(
            from: requestedURL
        )

        #expect(parameters["latitude"] == "-23.5505")
        #expect(parameters["longitude"] == "-46.6333")
        #expect(parameters["forecast_days"] == "7")
        #expect(parameters["timezone"] == "auto")

        let dailyFields = parameters["daily"] ?? ""

        #expect(dailyFields.contains("weather_code"))
        #expect(
            dailyFields.contains("temperature_2m_max")
        )
        #expect(
            dailyFields.contains("temperature_2m_min")
        )
        #expect(
            dailyFields.contains("precipitation_sum")
        )
        #expect(dailyFields.contains("snowfall_sum"))
        #expect(
            dailyFields.contains("wind_speed_10m_max")
        )
    }

    private func makeCity() -> City {
        City(
            id: 1,
            name: "São Paulo",
            country: "Brazil",
            adminArea: "São Paulo",
            latitude: -23.5505,
            longitude: -46.6333
        )
    }

    private func queryParameters(
        from url: URL
    ) -> [String: String] {
        let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: false
        )

        return Dictionary(
            uniqueKeysWithValues:
                (components?.queryItems ?? []).compactMap {
                    item in

                    guard let value = item.value else {
                        return nil
                    }

                    return (item.name, value)
                }
        )
    }
}

private actor APIClientSpy: APIClient {
    private let responseData: Data
    private var requestedURLs: [URL] = []

    init(responseData: Data) {
        self.responseData = responseData
    }

    func request<Response: Decodable & Sendable>(
        _ url: URL,
        responseType: Response.Type
    ) async throws -> Response {
        requestedURLs.append(url)

        return try JSONDecoder().decode(
            Response.self,
            from: responseData
        )
    }

    func lastRequestedURL() -> URL? {
        requestedURLs.last
    }
}
