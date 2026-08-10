//
//  DefaultActivityRankingService.swift
//  WhaToDo
//
//  Created by Natália Arantes on 06/08/26.
//

import Foundation

nonisolated struct DefaultActivityRankingService: ActivityRankingService {
    func rankActivities(
        for forecast: WeatherForecast
    ) -> [ActivityRecommend] {
        guard !forecast.days.isEmpty else {
            return []
        }

        let metrics = ForecastMetrics(days: forecast.days)

        let recommendations = [
            skiingRecommendation(using: metrics),
            surfingRecommendation(using: metrics),
            outdoorRecommendation(using: metrics),
            indoorRecommendation(using: metrics)
        ]

        return recommendations.sorted { first, second in
            if first.score == second.score {
                return first.activity.rawValue < second.activity.rawValue
            }

            return first.score > second.score
        }
    }
}

private extension DefaultActivityRankingService {
    struct ForecastMetrics {
        let averageTemperature: Double
        let totalPrecipitation: Double
        let totalSnowfall: Double
        let averageMaximumWindSpeed: Double
        let rainyDaysCount: Int
        let snowyDaysCount: Int

        init(days: [DailyWeather]) {
            let numberOfDays = Double(days.count)

            averageTemperature = days
                .map(\.averageTemperature)
                .reduce(0, +) / numberOfDays

            totalPrecipitation = days
                .map(\.precipitationSum)
                .reduce(0, +)

            totalSnowfall = days
                .map(\.snowfallSum)
                .reduce(0, +)

            averageMaximumWindSpeed = days
                .map(\.maximumWindSpeed)
                .reduce(0, +) / numberOfDays

            rainyDaysCount = days.filter {
                $0.precipitationSum >= 1
            }.count

            snowyDaysCount = days.filter {
                $0.snowfallSum > 0
            }.count
        }
    }

    func skiingRecommendation(using metrics: ForecastMetrics) -> ActivityRecommend {
        var score = 0
        var reasons: [String] = []

        if metrics.totalSnowfall >= 20 {
            score += 55
            reasons.append("Significant snowfall is expected.")
        } else if metrics.totalSnowfall >= 5 {
            score += 40
            reasons.append("Some snowfall is expected.")
        } else if metrics.totalSnowfall > 0 {
            score += 20
            reasons.append("Light snowfall is expected.")
        } else {
            reasons.append("No snowfall is expected.")
        }

        if metrics.averageTemperature <= 0 {
            score += 30
            reasons.append("Temperatures are suitable for snow conditions.")
        } else if metrics.averageTemperature <= 5 {
            score += 20
            reasons.append("Temperatures are relatively cold.")
        } else if metrics.averageTemperature <= 10 {
            score += 10
            reasons.append("Temperatures are cool but not ideal.")
        } else {
            reasons.append("Temperatures are too warm for skiing.")
        }

        if metrics.averageMaximumWindSpeed <= 25 {
            score += 15
            reasons.append("Wind conditions are manageable.")
        } else if metrics.averageMaximumWindSpeed <= 40 {
            score += 5
            reasons.append("Moderate winds may affect conditions.")
        } else {
            reasons.append("Strong winds may make skiing unsafe.")
        }

        return ActivityRecommend(activity: .skiing, score: normalized(score), reasons: reasons)
    }

    func surfingRecommendation(using metrics: ForecastMetrics) -> ActivityRecommend {
        var score = 0
        var reasons: [String] = []

        if 18...30 ~= metrics.averageTemperature {
            score += 40
            reasons.append("Temperatures are comfortable for water activities.")
        } else if 14..<18 ~= metrics.averageTemperature ||
                    30...34 ~= metrics.averageTemperature {
            score += 25
            reasons.append("Temperatures are acceptable for water activities.")
        } else {
            score += 10
            reasons.append("Temperatures may be uncomfortable for surfing.")
        }

        if 10...30 ~= metrics.averageMaximumWindSpeed {
            score += 35
            reasons.append("Moderate winds may support surfing conditions.")
        } else if metrics.averageMaximumWindSpeed < 10 {
            score += 20
            reasons.append("Winds may be too light for ideal conditions.")
        } else if metrics.averageMaximumWindSpeed <= 40 {
            score += 15
            reasons.append("Strong winds may create challenging conditions.")
        } else {
            reasons.append("Very strong winds may make surfing unsafe.")
        }

        if metrics.totalPrecipitation < 10 {
            score += 25
            reasons.append("Little rain is expected.")
        } else if metrics.totalPrecipitation < 30 {
            score += 15
            reasons.append("Some rain is expected.")
        } else {
            reasons.append("Heavy rain may affect surfing conditions.")
        }

        return ActivityRecommend(
            activity: .surfing,
            score: normalized(score),
            reasons: reasons
        )
    }

    func outdoorRecommendation(using metrics: ForecastMetrics) -> ActivityRecommend {
        var score = 0
        var reasons: [String] = []

        if 15...27 ~= metrics.averageTemperature {
            score += 45
            reasons.append("Temperatures are comfortable for outdoor activities.")
        } else if 10..<15 ~= metrics.averageTemperature ||
                    27...32 ~= metrics.averageTemperature {
            score += 30
            reasons.append("Temperatures are acceptable for outdoor activities.")
        } else {
            score += 10
            reasons.append("Temperatures may be uncomfortable outdoors.")
        }

        if metrics.totalPrecipitation < 5 {
            score += 35
            reasons.append("Very little rain is expected.")
        } else if metrics.totalPrecipitation < 20 {
            score += 20
            reasons.append("Some rain is expected.")
        } else {
            reasons.append("Frequent or heavy rain is expected.")
        }

        if metrics.averageMaximumWindSpeed <= 20 {
            score += 20
            reasons.append("Winds should remain light.")
        } else if metrics.averageMaximumWindSpeed <= 35 {
            score += 10
            reasons.append("Moderate winds are expected.")
        } else {
            reasons.append("Strong winds may affect outdoor activities.")
        }

        return ActivityRecommend(activity: .outdoorSightseeing,score: normalized(score),reasons: reasons
        )
    }

    func indoorRecommendation(using metrics: ForecastMetrics) -> ActivityRecommend {
        var score = 20
        var reasons: [String] = []

        if metrics.totalPrecipitation >= 30 {
            score += 35
            reasons.append("Heavy rain makes indoor activities more suitable.")
        } else if metrics.totalPrecipitation >= 10 {
            score += 25
            reasons.append("Rain is expected during the forecast period.")
        } else if metrics.rainyDaysCount > 0 {
            score += 10
            reasons.append("Some rainy periods are expected.")
        } else {
            reasons.append("Little rain is expected.")
        }

        if metrics.averageTemperature < 8 {
            score += 25
            reasons.append("Cold temperatures favor indoor activities.")
        } else if metrics.averageTemperature > 32 {
            score += 25
            reasons.append("Hot temperatures favor indoor activities.")
        } else if metrics.averageTemperature < 12 ||
                    metrics.averageTemperature > 28 {
            score += 15
            reasons.append("Temperatures may be uncomfortable outdoors.")
        } else {
            reasons.append("Temperatures are generally comfortable outdoors.")
        }

        if metrics.averageMaximumWindSpeed > 40 {
            score += 20
            reasons.append("Strong winds favor indoor activities.")
        } else if metrics.averageMaximumWindSpeed > 30 {
            score += 10
            reasons.append("Moderate to strong winds are expected.")
        }

        return ActivityRecommend(activity: .indoorSightseeing, score: normalized(score),reasons: reasons
        )
    }

    func normalized(_ score: Int) -> Int {
        min(max(score, 0), 100)
    }
}
