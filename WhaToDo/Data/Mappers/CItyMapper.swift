//
//  CItyMapper.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

enum CityMapper {
    static func map(_ dto: GeocodingCityDTO) -> City {
        City(
            id: dto.id,
            name: dto.name,
            country: dto.country ?? "Unknown",
            adminArea: dto.admin1,
            latitude: dto.latitude,
            longitude: dto.longitude
        )
    }
}
