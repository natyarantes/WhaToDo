//
//  APIClient.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

protocol APIClient: Sendable {
    func request<Response: Decodable & Sendable>(_ url: URL,responseType: Response.Type) async throws -> Response
}
