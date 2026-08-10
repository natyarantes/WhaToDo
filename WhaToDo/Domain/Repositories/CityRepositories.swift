//
//  CityRepositories.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

protocol CityRepositories: Sendable {
    func getCity(query: String) async throws -> [City]
}
