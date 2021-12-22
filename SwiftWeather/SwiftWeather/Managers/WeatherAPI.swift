//
//  Copyright (C) 2021 Thomas LEGRIS.
//

import RxSwift
import Foundation

// MARK: - Protocols
/// Stores methods for OpenWeatherMap API calls.
protocol WeatherApi {
    /// Requests local weather.
    ///
    /// - Parameters:
    ///     - cityName: name of the city
    /// - Returns: A single sequence with the weather info.
    func requestDailyWeather(cityName: String) -> Single<CommonWeatherModel?>
}

// MARK: - Public Enums
/// Stores potential errors which could occur during an API call.
enum WeatherManagerError: Error {
    case noData
    case badURL
    case jsonParsingError
}

// MARK: - Public Properties
extension WeatherManagerError {
    /// Returns title for error.
    var errorTitle: String {
        switch self {
        case .noData:
            return Localizable.errorNoData
        case .badURL:
            return Localizable.commonError
        case .jsonParsingError:
            return Localizable.errorUnknownCity
        }
    }
}
