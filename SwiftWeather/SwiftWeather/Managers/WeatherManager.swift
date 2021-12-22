//
//  Copyright (C) 2020 Thomas LEGRIS.
//

import Foundation
import RxSwift

/// Manager which handles methods relative to Weather API.
final class WeatherManager {
    // MARK: - Public Properties
    static let shared: WeatherManager = WeatherManager()

    // MARK: - Private Properties
    /// Returns the Open Weather Map API Key.
    private var apiKey: String {
        // Find Api plist file.
        guard let filePath = Bundle.main.path(forResource: "OpenWM-info", ofType: "plist") else {
            fatalError("No API plist file")
        }

        // Find the Api key.
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "api_key") as? String else {
            fatalError("No api_key for OWMap")
        }

        return value
    }

    // MARK: - Init
    private init() { }
}

// MARK: - Private Enums
private extension WeatherManager {
    /// Provides common constants.
    enum Constants {
        static let baseURL: String = "https://api.openweathermap.org/data/2.5/"
        static let tempUnit: String = "metric"
        static let cityParam: String = "q"
        static let unitsParam: String = "units"
        static let keyParam: String = "APPID"
    }

    /// Provides OWMap API endpoints.
    enum EndPoints {
        static let weatherEndPoint: String = "weather"
    }

    /// Provides all Http method types.
    enum HttpMethod {
        static let get: String = "GET"
        static let post: String = "POST"
        static let put: String = "PUT"
    }
}

// MARK: - WeatherApi
extension WeatherManager: WeatherApi {
    func requestDailyWeather(cityName: String) -> Single<CommonWeatherModel?> {
        let params: [String: String] = [Constants.cityParam: cityName,
                                        Constants.unitsParam: Constants.tempUnit,
                                        Constants.keyParam: self.apiKey]
        let single: Single<CommonWeatherModel?> = Single<CommonWeatherModel?>.create { single in
            self.sendRequest(endPoint: EndPoints.weatherEndPoint,
                             params: params,
                             completion: { model, error in
                                if let error = error {
                                    single(.failure(error))
                                } else {
                                    single(.success(model))
                                }
                             })
            return Disposables.create { }
        }

        return single
    }
}

// MARK: - Private Funcs
private extension WeatherManager {
    /// Handles the Data response with multiple verification and returns the response in a Data object if it's correct.
    ///
    /// - Parameters:
    ///    - endPoint: end point target
    ///    - params: json dict of query
    ///    - completion: callback with the server response
    func sendRequest(endPoint: String,
                     params: [String: String] = [:],
                     completion: @escaping (_ model: CommonWeatherModel?, _ error: Error?) -> Void) {
        guard let url = buildURLWithComponents(endPoint: endPoint, params: params) else {
            completion(nil, WeatherManagerError.badURL)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleResponse(data: data,
                                response: response,
                                error: error,
                                completion: completion)
        }.resume()
    }

    /// Handle the response with several checks.
    ///
    /// - Parameters:
    ///    - data: Data from the server
    ///    - response: Response from the server
    ///    - error: Error from the server
    ///    - completion: Callback with the server response which provides a weather model and an error
    func handleResponse(data: Data?,
                        response: URLResponse?,
                        error: Error?,
                        completion: @escaping (_ model: CommonWeatherModel?, _ error: Error?) -> Void) {
        guard error == nil else {
            completion(nil, error)
            return
        }

        guard let responseData = data else {
            completion(nil, WeatherManagerError.noData)
            return
        }

        let decoder = JSONDecoder()

        do {
            let jsonResponse = try decoder.decode(LocalWeatherResponse.self, from: responseData)

            guard let weather = jsonResponse.weather?.first else {
                completion(nil, WeatherManagerError.jsonParsingError)
                return
            }

            let groupIcon = groupFromId(identifier: weather.identifier).icon
            let weatherModel: CommonWeatherModel = CommonWeatherModel(temperature: jsonResponse.main.temp,
                                                                      icon: groupIcon,
                                                                      description: weather.main,
                                                                      cityName: jsonResponse.name)
            completion(weatherModel, nil)
        } catch let decodeError {
            print(decodeError)
            completion(nil, decodeError)
        }
    }

    /// Create an url with url components.
    ///
    /// - Parameters:
    ///    - endPoint: end point target
    ///    - params: json dict of query
    /// - Returns: The entire builded url.
    func buildURLWithComponents(endPoint: String, params: [String: String] = [:]) -> URL? {
        var components = URLComponents(string: Constants.baseURL + endPoint)
        components?.queryItems = params.map { element in URLQueryItem(name: element.key, value: element.value) }

        return components?.url
    }

    /// Returns weather group according to its identifier.
    ///
    /// - Parameters:
    ///     - identifier: weather call response id
    /// - Returns: A weather group associated to its id.
    func groupFromId(identifier: Int) -> WeatherGroup {
        switch identifier {
        case 200...232:
            return .thunder
        case 300...321:
            return .drizzle
        case 500...531:
            return .rain
        case 600...622:
            return .snow
        case 701...781:
            return .atmosphere
        case 800:
            return .clear
        default:
            return .clouds
        }
    }
}
