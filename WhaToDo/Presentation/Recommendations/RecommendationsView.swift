//
//  RecommendationsView.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import SwiftUI

struct RecommendationsView: View {
    @State private var viewModel: RecommendationsViewModel

    init(
        city: City,
        weatherRepository: WeatherRepository,
        rankingService: ActivityRankingService
    ) {
        _viewModel = State(
            initialValue: RecommendationsViewModel(
                city: city,
                weatherRepository: weatherRepository,
                rankingService: rankingService
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.state.isLoading &&
                !viewModel.state.hasContent {
                loadingView
            } else if let message = viewModel.state.errorMessage,
                      !viewModel.state.hasContent {
                errorView(message: message)
            } else if viewModel.state.hasContent {
                recommendationsContent
            } else {
                loadingView
            }
        }
        .navigationTitle(viewModel.city.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private var loadingView: some View {
        ProgressView("Loading recommendations...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label(
                "Unable to load recommendations",
                systemImage: "cloud.slash"
            )
        } description: {
            Text(message)
        } actions: {
            Button("Try again") {
                Task {
                    await viewModel.load()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var recommendationsContent: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                header

                if let refreshErrorMessage =
                    viewModel.state.refreshErrorMessage {
                    refreshErrorBanner(
                        message: refreshErrorMessage
                    )
                }

                ForEach(
                    Array(
                        viewModel.state.recommend.enumerated()
                    ),
                    id: \.element.id
                ) { index, recommendation in
                    ActivityRecommendCard(
                        rank: index + 1,
                        recommend: recommendation
                    )
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.city.displayName)
                .font(.title2.bold())

            Text(
                "Activity ranking based on the weather forecast for the next seven days."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

        }
    }

    private func refreshErrorBanner(
        message: String
    ) -> some View {
        Label(
            message,
            systemImage: "exclamationmark.triangle"
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(uiColor: .tertiarySystemBackground),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }
}

#Preview {
    NavigationStack {
        RecommendationsView(
            city: City(
                id: 1,
                name: "Belo Horizonte",
                country: "Brazil",
                adminArea: "Minas Gerais",
                latitude: -19.9167,
                longitude: -43.9345
            ),
            weatherRepository: PreviewWeatherRepository(),
            rankingService: PreviewActivityRankingService()
        )
    }
}
