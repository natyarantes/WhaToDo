//
//  ActivityRecommendCard.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import SwiftUI

struct ActivityRecommendCard: View {
    let rank: Int
    let recommend: ActivityRecommend

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                rankBadge

                Image(systemName: recommend.activity.systemImageName)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 32)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(recommend.activity.title)
                        .font(.headline)

                    Text(matchDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(recommend.score)")
                    .font(.title2.bold())
                    .monospacedDigit()
            }

            ProgressView(
                value: Double(recommend.score),
                total: 100
            )

            VStack(alignment: .leading, spacing: 6) {
                ForEach(recommend.reasons, id: \.self) { reason in
                    Label(reason, systemImage: "checkmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            Color(uiColor: .secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Rank \(rank), \(recommend.activity.title), score \(recommend.score) out of 100"
        )
        .accessibilityIdentifier("activity.card.\(rank)")
    }

    private var rankBadge: some View {
        Text("\(rank)")
            .font(.headline)
            .frame(width: 34, height: 34)
            .background(
                Color.accentColor.opacity(0.15),
                in: Circle()
            )
    }

    private var matchDescription: String {
        switch recommend.score {
        case 80...100:
            return "Excellent match"

        case 60..<80:
            return "Good match"

        case 40..<60:
            return "Fair match"

        default:
            return "Low match"
        }
    }
}
