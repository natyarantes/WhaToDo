//
//  DailyWeather.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct DailyWeather: Codable, Identifiable, Equatable, Sendable {
    var id: Date {
        date
    }
    
    let date: Date
    let minimumTemperature: Double
    let maximumTemperature: Double
    let precipitationSum: Double
    let snowfallSum: Double
    let maximumWindSpeed: Double
    let weatherCode: Int
    
    var averageTemperature: Double {
        (minimumTemperature + maximumTemperature) / 2
    }
}
