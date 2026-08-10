//
//  CitySearchViewModelTests.swift
//  WhaToDo
//
//  Created by Natália Arantes on 10/08/26.
//

import Foundation
import Testing
@testable import WhaToDo

@MainActor
struct CitySearchViewModelTests {
    @Test
    func successfulSearchPublishesCities() async {
        let expectedCity = makeCity()

        let repository = CityRepositoryStub(
            result: .success([expectedCity])
        )

        let viewModel = CitySearchViewModel(
            cityRepository: repository
        )

        viewModel.query = "London"

        await viewModel.search()

        guard case .results(let cities) = viewModel.state else {
            Issue.record("Expected results state")
            return
        }

        #expect(cities == [expectedCity])
    }

    @Test
    func searchWithoutResultsPublishesEmptyState() async {
        let repository = CityRepositoryStub(
            result: .success([])
        )

        let viewModel = CitySearchViewModel(
            cityRepository: repository
        )

        viewModel.query = "Unknown city"

        await viewModel.search()

        guard case .empty = viewModel.state else {
            Issue.record("Expected empty state")
            return
        }
    }

    @Test
    func repositoryFailurePublishesErrorState() async {
        let repository = CityRepositoryStub(
            result: .failure(.networkUnavailable)
        )

        let viewModel = CitySearchViewModel(
            cityRepository: repository
        )

        viewModel.query = "London"

        await viewModel.search()

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected error state")
            return
        }

        #expect(
            message
                == AppError.networkUnavailable.localizedDescription
        )
    }

    @Test
    func emptyQueryPublishesValidationError() async {
        let repository = CityRepositoryStub(
            result: .success([])
        )

        let viewModel = CitySearchViewModel(
            cityRepository: repository
        )

        viewModel.query = "   "

        await viewModel.search()

        guard case .error(let message) = viewModel.state else {
            Issue.record("Expected validation error")
            return
        }

        #expect(
            message
                == AppError.invalidSearchQuery.localizedDescription
        )
    }

    @Test
    func clearSearchReturnsToIdleState() async {
        let repository = CityRepositoryStub(
            result: .success([makeCity()])
        )

        let viewModel = CitySearchViewModel(
            cityRepository: repository
        )

        viewModel.query = "London"
        await viewModel.search()

        viewModel.clearSearch()

        #expect(viewModel.query.isEmpty)

        guard case .idle = viewModel.state else {
            Issue.record("Expected idle state")
            return
        }
    }
}

private extension CitySearchViewModelTests {
    func makeCity() -> City {
        City(
            id: 1,
            name: "London",
            country: "United Kingdom",
            adminArea: "England",
            latitude: 51.5072,
            longitude: -0.1276
        )
    }
}

private struct CityRepositoryStub: CityRepositories {
    enum Result: Sendable {
        case success([City])
        case failure(AppError)
    }

    let result: Result

    func getCity(query: String) async throws -> [City] {
        switch result {
        case .success(let cities):
            return cities

        case .failure(let error):
            throw error
        }
    }
}
