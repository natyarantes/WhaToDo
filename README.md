# WhaToDo

WhaToDo is a native iOS application that helps users decide what to do in a city based on the weather forecast for the next seven days. A user searches for a city, selects the intended location, and receives a ranked list of four activities:

- Skiing
- Surfing
- Outdoor sightseeing
- Indoor sightseeing

The app uses Open-Meteo for geocoding and weather data. No API key or backend is required.

## Features

- City search with explicit idle, loading, results, empty, and error states
- Seven-day weather forecast from Open-Meteo
- Deterministic and explainable activity ranking from 0 to 100
- User-facing reasons for every recommendation
- Retry support for failed searches and forecast requests
- Pull-to-refresh while preserving existing content if refresh fails
- Dependency-injected data and domain layers
- Unit tests that run without network access
- Deterministic UI tests using launch arguments and test dependencies
- VoiceOver-friendly activity summaries and accessibility identifiers for UI automation

## Platform and tooling

- **Platform:** iOS 17.6+
- **Language:** Swift
- **UI:** SwiftUI
- **Architecture:** MVVM with layered data and domain boundaries
- **State observation:** Observation (`@Observable`)
- **Concurrency:** Swift concurrency with `async`/`await`
- **Dependency injection:** Manual, protocol-based injection
- **Unit tests:** Swift Testing
- **UI tests:** XCTest and XCUITest
- **Dependencies:** Apple frameworks only

The project deliberately avoids third-party packages. Its dependency graph is small enough for manual injection to remain explicit and easy to follow.

## Architecture

The code is separated into four main areas:

```text
SwiftUI View
    ↓ user actions / rendered state
ViewModel
    ↓ domain-facing protocol
Repository / Ranking Service
    ↓
APIClient → Open-Meteo
```

### App

`AppContainer` is the composition root. It creates the live `URLSessionAPIClient`, repositories, and ranking service, then injects them into the initial view. It also provides preview and UI-testing dependency graphs.

### Presentation

SwiftUI views render state and forward user actions. They do not build URLs, decode responses, or calculate recommendation scores.

The view models expose explicit state:

- City search: `idle`, `loading`, `results`, `empty`, and `error`
- Recommendations: forecast, ranked recommendations, initial loading/error, and independent refresh loading/error

Keeping initial-load and refresh errors separate allows the app to preserve useful content when a refresh fails.

### Domain

The domain layer contains application models, repository protocols, errors, and `ActivityRankingService`. It does not know about SwiftUI or Open-Meteo response shapes.

### Data

The data layer contains:

- API response DTOs
- DTO-to-domain mappers
- `URLSessionAPIClient`
- Open-Meteo repository implementations
- Cache contracts reserved for a future offline implementation

DTOs are mapped at the data boundary, so API-specific parallel arrays and coding keys do not leak into view models or views.

## Project structure

```text
WhaToDo/
├── App/                    # Entry point and dependency composition
├── Data/
│   ├── Cache/              # Cache contract and cached model
│   ├── DTO/                # Open-Meteo response types
│   ├── Mappers/            # DTO-to-domain conversion
│   ├── Network/            # API client abstraction and URLSession client
│   └── Repositories/       # Live repository implementations
├── Domain/
│   ├── Models/             # City, forecast, weather and recommendation models
│   ├── Repositories/       # Repository protocols
│   └── Services/           # Recommendation ranking
├── Presentation/
│   ├── CitySearch/
│   ├── Components/
│   └── Recommendations/
└── Support/                # Preview and UI-test dependencies

WhaToDoTests/               # Unit and integration-boundary tests
WhaToDoUITests/             # Deterministic end-to-end UI flows
```

## API usage

The app uses two free, keyless Open-Meteo endpoints:

### Geocoding

```text
GET https://geocoding-api.open-meteo.com/v1/search
```

Parameters include the city name, a maximum of ten results, English response names, and JSON format. The selected result supplies the latitude and longitude required by the forecast endpoint.

### Forecast

```text
GET https://api.open-meteo.com/v1/forecast
```

The request uses `forecast_days=7`, `timezone=auto`, and these daily fields:

- `weather_code`
- `temperature_2m_max`
- `temperature_2m_min`
- `precipitation_sum`
- `snowfall_sum`
- `wind_speed_10m_max`

Open-Meteo defaults are used: degrees Celsius, millimetres of rain, centimetres of snow, and kilometres per hour for wind.

Open-Meteo represents daily values as parallel arrays. `WeatherForecastMapper` verifies that every array has the same length before accessing it by index, validates each date, and rejects an empty forecast.

## Recommendation logic

### What the score represents

Each activity receives a score from **0 to 100**. The score is a comparative suitability signal for the selected city's upcoming seven-day period. It is not a probability, a scientific weather index, or safety advice.

The current implementation produces one weekly ranking by aggregating all seven forecast days. The aggregation uses:

- **Average temperature:** the mean of each day's `(minimum + maximum) / 2`
- **Total precipitation:** the sum of daily precipitation in millimetres
- **Total snowfall:** the sum of daily snowfall in centimetres
- **Average maximum wind:** the mean of the daily maximum wind speeds in km/h
- **Rainy days:** days with at least 1 mm of precipitation

The algorithm is intentionally rule-based. Its output is deterministic, inspectable, inexpensive to compute, and straightforward to unit test.

### How the weights were chosen

The weights are product heuristics, not values returned by Open-Meteo. They follow three principles:

1. **Essential conditions receive the largest share.** Snow accounts for up to 55 points for skiing; comfortable temperature accounts for up to 45 points for outdoor sightseeing.
2. **Supporting conditions receive a smaller share.** Wind contributes 15 points to skiing but 35 to surfing because it has greater influence on the surfing proxy used here.
3. **The best plausible combination totals 100.** This makes activities easy to compare without adding arbitrary normalization after scoring.

Thresholds are deliberately broad rather than falsely precise. They represent understandable comfort and weather bands that should later be validated with domain experts and product data.

### Skiing: 55% snow, 30% temperature, 15% wind

Snow is treated as the primary requirement, temperature as the condition that helps preserve it, and wind as an operational comfort/safety modifier.

| Component | Forecast condition | Points |
|---|---:|---:|
| Total snowfall | ≥ 20 cm | 55 |
| | 5–19.99 cm | 40 |
| | > 0 and < 5 cm | 20 |
| | 0 cm | 0 |
| Average temperature | ≤ 0°C | 30 |
| | > 0°C and ≤ 5°C | 20 |
| | > 5°C and ≤ 10°C | 10 |
| | > 10°C | 0 |
| Average maximum wind | ≤ 25 km/h | 15 |
| | > 25 and ≤ 40 km/h | 5 |
| | > 40 km/h | 0 |

Example: 24 cm of snow, an average temperature of -2°C, and 20 km/h wind scores `55 + 30 + 15 = 100`.

### Surfing: 40% temperature, 35% wind, 25% rain

The free forecast request does not contain wave height, swell period, tides, currents, water temperature, or beach exposure. The surfing score is therefore explicitly a **general weather proxy**, not a surf-condition forecast.

| Component | Forecast condition | Points |
|---|---:|---:|
| Average temperature | 18–30°C | 40 |
| | 14–<18°C or >30–34°C | 25 |
| | Outside those ranges | 10 |
| Average maximum wind | 10–30 km/h | 35 |
| | < 10 km/h | 20 |
| | > 30 and ≤ 40 km/h | 15 |
| | > 40 km/h | 0 |
| Total precipitation | < 10 mm | 25 |
| | 10–<30 mm | 15 |
| | ≥ 30 mm | 0 |

Temperature receives the largest share as a basic comfort proxy. Moderate wind receives substantial weight because completely calm or extreme conditions are less useful for this simplified model. Rain has the smallest share because it affects general comfort but cannot substitute for missing swell data.

### Outdoor sightseeing: 45% temperature, 35% rain, 20% wind

| Component | Forecast condition | Points |
|---|---:|---:|
| Average temperature | 15–27°C | 45 |
| | 10–<15°C or >27–32°C | 30 |
| | Outside those ranges | 10 |
| Total precipitation | < 5 mm | 35 |
| | 5–<20 mm | 20 |
| | ≥ 20 mm | 0 |
| Average maximum wind | ≤ 20 km/h | 20 |
| | > 20 and ≤ 35 km/h | 10 |
| | > 35 km/h | 0 |

Temperature has the largest share because sightseeing commonly involves spending several hours outside. Rain is the next strongest constraint, while wind acts as a secondary comfort factor.

Example: an average of 21°C, 3 mm total rain, and 15 km/h average maximum wind scores `45 + 35 + 20 = 100`.

### Indoor sightseeing: 20-point baseline plus weather penalties

Indoor activities start at **20 points** because they remain feasible in almost any weather. They gain points when outdoor conditions become less comfortable.

| Component | Forecast condition | Additional points |
|---|---:|---:|
| Baseline | Always | 20 |
| Total precipitation | ≥ 30 mm | +35 |
| | 10–<30 mm | +25 |
| | < 10 mm with at least one rainy day | +10 |
| | No rainy days | +0 |
| Average temperature | < 8°C or > 32°C | +25 |
| | 8–<12°C or >28–32°C | +15 |
| | 12–28°C | +0 |
| Average maximum wind | > 40 km/h | +20 |
| | > 30 and ≤ 40 km/h | +10 |
| | ≤ 30 km/h | +0 |

The maximum is `20 + 35 + 25 + 20 = 100`. This inverse design keeps indoor sightseeing viable in good weather without allowing it to dominate, while making it competitive during rain, temperature extremes, or strong wind.

### Normalization and tie-breaking

Every final score is clamped to `0...100` as a defensive guarantee. Recommendations are sorted by descending score. Equal scores use the activity's stable raw-value order as a deterministic tie-breaker. Determinism prevents UI reshuffling and makes tests repeatable.

### Important limitations

- A city coordinate does not prove that a ski slope, suitable beach, museum, or attraction exists nearby.
- Scores do not account for opening hours, distance, user preferences, ability, equipment, terrain, hazards, or official warnings.
- Surfing lacks marine data and should be labelled as an approximation.
- Seven-day aggregation can hide day-to-day variation. A production iteration could rank activities per day or highlight each activity's best day.
- The bands and weights require validation with domain experts, analytics, and user feedback before being treated as a product recommendation model.

## Error handling

Network, HTTP, malformed response, decoding, empty-forecast, validation, and unknown failures map to `AppError` values with user-facing messages. The UI distinguishes an initial failure from a refresh failure: initial failures replace the loading state, while refresh failures preserve already visible recommendations and show a non-destructive message.

## Build and run

Requirements:

- A Mac with a recent Xcode version
- An iOS 17.6+ simulator or compatible device
- Internet access for live city and forecast requests

Steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/natyarantes/WhaToDo.git
   cd WhaToDo
   ```

2. Open `WhaToDo.xcodeproj` in Xcode.
3. Select the `WhaToDo` scheme and an iPhone simulator.
4. Run with **Product → Run** or `⌘R`.

No secrets, API keys, package installation, or backend configuration are required.

## Testing

Run all tests with **Product → Test** or `⌘U`. Individual tests can be run from Xcode's Test Navigator (`⌘6`).

### Unit-test strategy

The unit suite focuses on logic and state transitions with the highest regression risk:

- Ranking outcomes for snowy/cold, mild/dry, and extreme-weather scenarios
- Score bounds, ordering, and empty forecasts
- Forecast DTO mapping, invalid parallel-array lengths, invalid dates, and empty data
- City-search success, empty, validation, clearing, and repository failure states
- Recommendation loading, refresh, failure, and content preservation
- Repository URL/query construction and DTO-to-domain integration
- HTTP success, non-2xx responses, malformed JSON, and offline errors

Repositories and services are injected through protocols. Tests use stubs, spies, actors, controlled JSON, and a custom `URLProtocol`, so unit tests never require the network.

### UI-test strategy

UI tests launch the app with `-ui-testing`. `AppContainer` then selects deterministic repositories instead of live services. Additional launch arguments select success, empty, and error scenarios.

The UI suite covers:

- App launch
- Search, result selection, navigation, and the first ranked recommendation
- Empty search results
- Search failure, error message, and retry affordance

This boundary gives meaningful end-to-end coverage without making tests dependent on Open-Meteo availability or response data.

## Assumptions

- The selected geocoding result is the location the user intended.
- Open-Meteo default units are appropriate for the ranking rules.
- A weekly aggregate ranking is sufficient for the first version.
- Weather is the only ranking input; availability and proximity of activities are out of scope.
- English-only UI and metric units are acceptable for this exercise.

## Trade-offs and omissions

The implementation prioritizes architecture, correctness, testability, and communication over feature volume and visual polish.

Not included:

- Production offline cache (cache contracts exist, but live repositories currently fetch from the network)
- Search debounce, pagination, history, or favourites
- Current-location support
- Marine forecast and wave data
- Attraction discovery and distance calculation
- Per-day recommendation screens
- Localization and user-selectable units
- Snapshot testing and exhaustive UI testing
- Automated retry/backoff and network reachability monitoring

`forceRefresh` is already represented at the repository boundary so cache behaviour can be added without changing presentation APIs.

## Production readiness

Before production, I would add:

- A time-bounded offline/stale cache with clear provenance in the UI
- Retry with exponential backoff for transient failures
- Structured logging, crash reporting, performance monitoring, and analytics
- CI that builds the app and runs unit/UI tests on pull requests
- Localization, unit preferences, Dynamic Type, VoiceOver, contrast, and broader accessibility audits
- API contract tests and monitoring for response-shape changes
- Product and domain-expert validation of ranking bands and weights
- Marine data for surfing and location/category data to verify activity availability
- Remote configuration or versioning for ranking rules
- Privacy documentation and an App Store release checklist

## Cross-platform delivery

The boundaries map naturally to Android:

- SwiftUI views → Jetpack Compose
- Observation view models → ViewModels exposing `StateFlow`
- async/await → Kotlin coroutines
- Swift protocols → Kotlin interfaces
- repositories and mappers → equivalent Kotlin data-layer components

The deterministic ranking rules and Open-Meteo contracts can be ported directly. For this scope, separate native implementations keep platform code idiomatic. If both platforms evolved together and rule parity became expensive, the domain models and ranking engine would be candidates for Kotlin Multiplatform sharing.

## AI usage disclosure

AI assistance was used during implementation to discuss architecture, generate candidate test cases, troubleshoot UI-test accessibility queries, and help draft documentation. The implementation, weights, API fields, state transitions, and test behaviour were reviewed against the source code and executed locally. AI-generated output was not accepted without verification.
