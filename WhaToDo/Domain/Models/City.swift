//
//  City.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct City: Identifiable, Equatable, Hashable, Codable, Sendable {
    let id: Int
    let name: String
    let country: String
    let adminArea: String?
    let latitude: Double
    let longitude: Double

    var displayName: String {
        [name, adminArea, country]
            .compactMap { value in
                guard let value, !value.isEmpty else {
                    return nil
                }

                return value
            }
            .joined(separator: ", ")
    }
}
