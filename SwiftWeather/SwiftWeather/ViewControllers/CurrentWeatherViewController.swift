//
//  Copyright (C) 2020 Thomas LEGRIS.
//

import UIKit
import Reachability
import SwiftyUserDefaults
import RxSwift

/// Screen which shows location weather for a targetted city.
final class CurrentWeatherViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var weatherInfoWidget: WeatherInfoWidget!
    @IBOutlet private weak var nameCityLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var refreshButton: UIButton!
    @IBOutlet private weak var cityTextField: UITextField!
    @IBOutlet private weak var timeView: UIView!

    // MARK: - Private Properties
    private var cityName: String? {
        didSet {
            nameCityLabel.text = cityName
        }
    }
    private var disposeBag: DisposeBag = DisposeBag()

    /// Returns true if connected to internet, false otherwise.
    private var isNetworkReachable: Bool {
        let reachability = try? Reachability()

        return reachability?.connection == .wifi ||  reachability?.connection == .cellular
    }

    // MARK: - Private Enums
    private enum Constants {
        static let cornerRadius: CGFloat = 9.0
        static let borderWidth: CGFloat = 1.0
    }

    // MARK: - Override Funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        requestWeather()
    }
}

// MARK: - Actions
private extension CurrentWeatherViewController {
    @IBAction func searchButtonTouchedUpInside(_ sender: Any) {
        requestWeather()
    }

    @IBAction func refreshButtonTouchedUpInside(_ sender: Any) {
        refreshButton.startRotate(repeatCount: 1.0)
        requestWeather()
    }
}

// MARK: - Private Funcs
private extension CurrentWeatherViewController {
    /// Inits the view.
    func initView() {
        timeLabel.text = "Last updated weather at \(Defaults.lastSearchedCity)"
        timeLabel.textColor = ColorName.black60.color
        topView.cornerRadiusedWith(backgroundColor: ColorName.white20,
                                   borderColor: ColorName.white80.color,
                                   radius: Constants.cornerRadius,
                                   borderWidth: Constants.borderWidth)

        weatherInfoWidget.cornerRadiusedWith(backgroundColor: ColorName.white20,
                                             borderColor: ColorName.white80.color,
                                             radius: Constants.cornerRadius,
                                             borderWidth: Constants.borderWidth)
        updateCityName(with: Defaults.lastSearchedCity)
        timeView.isHidden = Defaults.lastUpdatedDate.isEmpty
    }

    /// Returns weather last updated time in hour.
    func updateLastUpdateDate() {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        Defaults.lastUpdatedDate = formatter.string(from: currentDateTime)
        timeView.isHidden = Defaults.lastUpdatedDate.isEmpty
        timeLabel.text = "Last updated weather at \(Defaults.lastUpdatedDate)"
    }

    /// Updates current city name.
    ///
    /// - Parameters:
    ///     - city: new targetted city
    func updateCityName(with city: String?) {
        guard let city = city else {
            cityName = Localizable.errorUnknownLocation
            return
        }

        cityName = city
    }

    /// Call the manager in order to get weather information.
    func requestWeather() {
        guard isNetworkReachable else {
            self.showAlert(withTitle: Localizable.commonError,
                           message: Localizable.errorNoInternet)
            return
        }

        let city = cityTextField.text?.isEmpty == true ? Defaults.lastSearchedCity : cityTextField.text

        guard let cityName = city,
              city?.isEmpty == false else {
            return
        }

        WeatherManager.shared.requestDailyWeather(cityName: cityName)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { model in
                guard let weatherModel = model else {
                    self.showAlert(withTitle: Localizable.commonError,
                                   message: Localizable.errorUnknownCity)
                    return
                }

                self.updateView(model: weatherModel)
            }, onFailure: { error in
                guard let weatherError = error as? WeatherManagerError else {
                    self.showAlert(withTitle: Localizable.commonError,
                                   message: Localizable.errorNoInfo)
                    return
                }

                self.showAlert(withTitle: weatherError.errorTitle,
                               message: Localizable.errorNoInfo)

            })
            .disposed(by: disposeBag)
    }

    /// Updates the view.
    ///
    /// - Parameters:
    ///     - model: weather model returned by the webservice
    func updateView(model: CommonWeatherModel) {
        Defaults.lastSearchedCity = model.cityName ?? ""
        self.weatherInfoWidget.model = model
        self.updateCityName(with: model.cityName)
        self.updateLastUpdateDate()
    }
}
