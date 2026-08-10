//
//  URLSessionAPIClient.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

struct URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func request<Response: Decodable & Sendable>(_ url: URL,responseType: Response.Type) async throws -> Response {
        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.invalidResponse
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw AppError.requestFailed
            }

            do {
                return try decoder.decode(
                    Response.self,
                    from: data
                )
            } catch {
                throw AppError.decodingFailed
            }
        } catch let error as AppError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .cannotConnectToHost,
                 .cannotFindHost:
                throw AppError.networkUnavailable

            default:
                throw AppError.requestFailed
            }
        } catch {
            throw AppError.unknown
        }
    }
}
