//
//  URLSessionAPIClientTests.swift
//  WhaToDo
//
//  Created by Natália Arantes on 10/08/26.
//

import Foundation
import Testing
@testable import WhaToDo

@Suite(.serialized)
struct URLSessionAPIClientTests {
    @Test
    func successfulResponseIsDecoded() async throws {
        let json = """
        {
          "results": [
            {
              "id": 1,
              "name": "London",
              "latitude": 51.5072,
              "longitude": -0.1276,
              "country": "United Kingdom",
              "admin1": "England"
            }
          ]
        }
        """

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return (response, Data(json.utf8))
        }

        let client = makeClient()

        let response = try await client.request(
            makeURL(),
            responseType: GeocodingResponseDTO.self
        )

        #expect(response.results?.count == 1)
        #expect(response.results?.first?.name == "London")
    }

    @Test
    func unsuccessfulHTTPStatusThrowsRequestFailed() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!

            return (response, Data())
        }

        let client = makeClient()

        do {
            let _: GeocodingResponseDTO =
                try await client.request(
                    makeURL(),
                    responseType: GeocodingResponseDTO.self
                )

            Issue.record(
                "Expected AppError.requestFailed"
            )
        } catch {
            #expect(error as? AppError == .requestFailed)
        }
    }

    @Test
    func invalidJSONThrowsDecodingFailed() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return (
                response,
                Data("invalid-json".utf8)
            )
        }

        let client = makeClient()

        do {
            let _: GeocodingResponseDTO =
                try await client.request(
                    makeURL(),
                    responseType: GeocodingResponseDTO.self
                )

            Issue.record(
                "Expected AppError.decodingFailed"
            )
        } catch {
            #expect(error as? AppError == .decodingFailed)
        }
    }

    @Test
    func offlineErrorThrowsNetworkUnavailable() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let client = makeClient()

        do {
            let _: GeocodingResponseDTO =
                try await client.request(
                    makeURL(),
                    responseType: GeocodingResponseDTO.self
                )

            Issue.record(
                "Expected AppError.networkUnavailable"
            )
        } catch {
            #expect(
                error as? AppError == .networkUnavailable
            )
        }
    }

    private func makeClient() -> URLSessionAPIClient {
        let configuration =
            URLSessionConfiguration.ephemeral

        configuration.protocolClasses = [
            MockURLProtocol.self
        ]

        let session = URLSession(
            configuration: configuration
        )

        return URLSessionAPIClient(session: session)
    }

    private func makeURL() -> URL {
        URL(string: "https://example.com/test")!
    }
}

private final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler:
        ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(
        with request: URLRequest
    ) -> Bool {
        true
    }

    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(
                self,
                didFailWithError: AppError.unknown
            )
            return
        }

        do {
            let (response, data) = try handler(request)

            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )

            client?.urlProtocol(
                self,
                didLoad: data
            )

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(
                self,
                didFailWithError: error
            )
        }
    }

    override func stopLoading() {}
}
