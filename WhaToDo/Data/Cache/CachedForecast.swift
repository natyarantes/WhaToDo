//
//  CachedForecast.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct CachedForecast: Codable, Equatable, Sendable {
    let forecast: WeatherForecast
    let savedAt: Date
    
    func isValid(at currentDate: Date, expirationInterval: TimeInterval) -> Bool {
        currentDate.timeIntervalSince(savedAt) < expirationInterval
    }
}
