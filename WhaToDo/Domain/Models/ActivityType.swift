//
//  ActivityType.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

enum ActivityType: String, CaseIterable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing
    
    var title: String {
        switch self {
            case .skiing:
            return "Skiing"
        case .surfing:
            return "Surfing"
        case .outdoorSightseeing:
            return "Sightseeing"
        case .indoorSightseeing:
            return "Sightseeing"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .skiing:
            return "ski.fill"
        case .surfing:
            return "waves.circle.fill"
        case .outdoorSightseeing:
            return "map.fill"
        case .indoorSightseeing:
            return "house.fill"
        }
    }
}
