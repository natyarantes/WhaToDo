//
//  ActivityRankingService.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

protocol ActivityRankingService {
    func rankActivities(for forecast: WeatherForecast) -> [ActivityRecommend]
}
