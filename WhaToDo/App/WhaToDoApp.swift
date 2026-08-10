//
//  WhaToDoApp.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import SwiftUI

@main
struct WhaToDoApp: App {
    private let container = AppContainer.current

    var body: some Scene {
        WindowGroup {
            CitySearchView(
                cityRepository: container.cityRepository,
                weatherRepository: container.weatherRepository,
                rankingService: container.rankingService
            )
        }
    }
}
