//
//  WeatherRepository.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

protocol WeatherRepository: Sendable {
    func fetchForecast(for city: City, forceRefresh: Bool) async throws -> ForecastResult
}
