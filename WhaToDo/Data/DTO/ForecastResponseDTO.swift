//
//  ForecastResponseDTO.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

nonisolated struct ForecastResponseDTO: Decodable, Sendable {
    let daily: DailyForecastDTO
}

nonisolated struct DailyForecastDTO: Decodable, Sendable {
    let time: [String]
    let weatherCode: [Int]
    let temperatureMax: [Double]
    let temperatureMin: [Double]
    let precipitationSum: [Double]
    let snowfallSum: [Double]
    let windSpeedMax: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
        case precipitationSum = "precipitation_sum"
        case snowfallSum = "snowfall_sum"
        case windSpeedMax = "wind_speed_10m_max"
    }
}
