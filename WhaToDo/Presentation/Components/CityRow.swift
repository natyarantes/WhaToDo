//
//  CityRow.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import SwiftUI

struct CityRow: View {
    let city: City

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.headline)

                Text(locationDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var locationDescription: String {
        [city.adminArea, city.country]
            .compactMap { value in
                guard let value, !value.isEmpty else {
                    return nil
                }

                return value
            }
            .joined(separator: ", ")
    }
}
