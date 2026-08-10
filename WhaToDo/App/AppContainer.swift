//
//  AppContainer.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct AppContainer {
    let cityRepository: CityRepositories
    let weatherRepository: WeatherRepository
    let rankingService: ActivityRankingService

    static let live: AppContainer = {
        let apiClient = URLSessionAPIClient()

        return AppContainer(
            cityRepository: DefaultCityRepository(apiClient: apiClient),
            weatherRepository: DefaultWeatherRepository(apiClient: apiClient),
            rankingService: DefaultActivityRankingService()
        )
    }()

    static let preview = AppContainer(
        cityRepository: PreviewCityRepository(),
        weatherRepository: PreviewWeatherRepository(),
        rankingService: PreviewActivityRankingService()
    )
}
