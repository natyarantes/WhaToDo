//
//  GeocodingResponseDTO.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

nonisolated struct GeocodingResponseDTO: Decodable, Sendable {
    let results: [GeocodingCityDTO]?
}

nonisolated struct GeocodingCityDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
}
