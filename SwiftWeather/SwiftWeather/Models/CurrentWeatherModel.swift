//
//  Copyright (C) 2020 Thomas LEGRIS.
//

import UIKit

// MARK: - Structs
/// Model used for updating the custom widget view.
struct CommonWeatherModel {
    // MARK: - Public Properties
    var temperature: Float?
    var icon: UIImage?
    var description: String?
    var cityName: String?
}

// MARK: - Public Enums
/// Provides different weather description.
enum WeatherGroup {
    case thunder
    case drizzle
    case rain
    case snow
    case atmosphere
    case clear
    case clouds

    /// Icon corresponding to the current weather description.
    var icon: UIImage {
        switch self {
        case .thunder:
            return Asset.icThunder.image
        case .rain,
             .drizzle:
            return Asset.icRain.image
        case .snow:
            return Asset.icSnow.image
        case .atmosphere:
            return Asset.icFog.image
        case .clear:
            return Asset.icSun.image
        case .clouds:
            return Asset.icSunCloudy.image
        }
    }
}
