//
//  ForecastCache.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

protocol ForecastCache: Sendable {
    func loadForecast(for city: City) async throws -> CachedForecast?
    
    func saveForecast(_ forecast: WeatherForecast, for city: City) async throws
}
