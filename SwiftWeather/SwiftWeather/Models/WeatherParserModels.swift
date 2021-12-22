//
//  Copyright (C) 2020 Thomas LEGRIS.
//

/// Files which provides several OpenWeatherMap response model.

// MARK: - Structs
/// Model for a city weather response.
struct LocalWeatherResponse: Codable {
    // MARK: - Internal Properties
    var weather: [WeatherField]?
    var main: MainField
    var name: String

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case weather
        case main
        case name
    }
}

/// Model for the `weather` field in the JSON Response.
struct WeatherField: Codable {
    var identifier: Int
    var main: String
    var description: String
    var icon: String

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case main
        case description
        case icon
    }
}

/// Model for the `main` field in the JSON Response.
struct MainField: Codable {
    var temp: Float
    var pressure: Float
    var humidity: Float
    var tempMin: Float
    var tempMax: Float

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case temp
        case pressure
        case humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}
