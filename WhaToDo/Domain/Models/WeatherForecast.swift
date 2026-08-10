//
//  WeatherForecast.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct WeatherForecast: Codable, Equatable, Sendable {
    let city: City
    let days: [DailyWeather] //keeps the 7 fetched days
    let fetchedAt: Date
}
