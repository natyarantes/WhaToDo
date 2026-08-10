//
//  AppError.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

enum AppError: LocalizedError, Equatable, Sendable {
    case invalidSearchQuery
    case cityNotFound
    case invalidURL
    case invalidResponse
    case networkUnavailable
    case requestFailed
    case decodingFailed
    case noForecastAvailable
    case cacheUnavailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidSearchQuery:
            return "Enter a city name to start searching."

        case .cityNotFound:
            return "No cities were found for this search."

        case .invalidURL:
            return "The request could not be created."

        case .invalidResponse:
            return "The weather service returned an invalid response."

        case .networkUnavailable:
            return "You appear to be offline."

        case .requestFailed:
            return "We could not complete the request."

        case .decodingFailed:
            return "The weather information could not be processed."

        case .noForecastAvailable:
            return "No forecast is available for this city."

        case .cacheUnavailable:
            return "Saved weather information could not be loaded."

        case .unknown:
            return "Unexpected error."
        }
    }
}
