//
//  PreviewDependencies.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct PreviewCityRepository: CityRepositories {   
    
    func getCity(query: String) async throws -> [City] {
        [
            City(
                id: 1,
                name: "São Paulo",
                country: "Brazil",
                adminArea: "São Paulo",
                latitude: -23.5505,
                longitude: -46.6333
            ),
            City(
                id: 2,
                name: "Belo Horizonte",
                country: "Brazil",
                adminArea: "Minas Gerais",
                latitude: -19.9167,
                longitude: -43.9345
            )
        ]
    }
}

struct PreviewWeatherRepository: WeatherRepository {
    func fetchForecast(
        for city: City,
        forceRefresh: Bool
    ) async throws -> ForecastResult {
        ForecastResult(forecast: WeatherForecast(
                city: city,
                days: [],
                fetchedAt: Date()
            )
        )
    }
}

struct PreviewActivityRankingService: ActivityRankingService {
    func rankActivities(
        for forecast: WeatherForecast
    ) -> [ActivityRecommend] {
        []
    }
}
