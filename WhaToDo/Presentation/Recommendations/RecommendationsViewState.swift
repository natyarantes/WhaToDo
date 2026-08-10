//
//  RecommendationsViewState.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct RecommendationsViewState: Equatable {
    var forecast: WeatherForecast?
    var recommend: [ActivityRecommend] = []

    var isLoading = false
    var isRefreshing = false

    var errorMessage: String?
    var refreshErrorMessage: String?

    var hasContent: Bool {
        forecast != nil && !recommend.isEmpty
    }

    static let initial = RecommendationsViewState()
}
