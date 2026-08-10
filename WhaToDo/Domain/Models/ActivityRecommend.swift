//
//  ActivityRecommendation.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct ActivityRecommend: Identifiable, Equatable, Sendable {
    var id: ActivityType {
        activity
    }
    
    let activity: ActivityType
    let score: Int
    let reasons: [String]
}
