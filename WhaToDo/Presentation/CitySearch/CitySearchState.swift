//
//  CitySearchState.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

enum CitySearchState {
    case idle
    case loading
    case results([City])
    case empty
    case error(String)
}
