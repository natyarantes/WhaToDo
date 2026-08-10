//
//  CItySearchView.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import SwiftUI

struct CitySearchView: View {
    @State private var viewModel: CitySearchViewModel

    private let weatherRepository: WeatherRepository
    private let rankingService: ActivityRankingService

    init(
        cityRepository: CityRepositories,
        weatherRepository: WeatherRepository,
        rankingService: ActivityRankingService
    ) {
        _viewModel = State(
            initialValue: CitySearchViewModel(
                cityRepository: cityRepository
            )
        )

        self.weatherRepository = weatherRepository
        self.rankingService = rankingService
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("WhaToDo")
                .searchable(
                    text: $viewModel.query,
                    prompt: "Search for a city"
                )
                .onSubmit(of: .search) {
                    performSearch()
                }
                .toolbar {
                    if !viewModel.query.isEmpty {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Clear") {
                                viewModel.clearSearch()
                            }
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "Find your next activity",
                systemImage: "cloud.sun",
                description: Text(
                    "Search for a city to see activity recommendations for the next seven days."
                )
            )

        case .loading:
            ProgressView("Searching cities...")

        case .results(let cities):
            List(cities) { city in
                NavigationLink {
                    RecommendationsView(city: city,
                                        weatherRepository: weatherRepository,
                                        rankingService: rankingService)
                } label: {
                    CityRow(city: city)
                }
            }
            .listStyle(.plain)

        case .empty:
            ContentUnavailableView.search(
                text: viewModel.query
            )

        case .error(let message):
            ContentUnavailableView {
                Label(
                    "Unable to search",
                    systemImage: "exclamationmark.triangle"
                )
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private func performSearch() {
        Task {
            await viewModel.search()
        }
    }

    private func recommendationsPlaceholder(
        for city: City
    ) -> some View {
        Text(city.displayName)
            .navigationTitle("Recommendations")
    }
}
