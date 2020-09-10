//
//  WeatherViewModel.swift
//  World Weather
//
//  Created by Ashish Bansal on 07/09/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import Foundation
import UIKit.UIImage

func convertKelvinToCelsius(_ kelvin: Double) -> String {
    let celsiusTemp = kelvin - 273.15
    return String(format: "%.1f°C", celsiusTemp)
}

class Box<T> {
    typealias Listener = (T?) -> Void
    
    private var listener: Listener?
    
    var value: T? {
        didSet {
            listener?(value)
        }
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}

class WeatherViewModel {
    static let countOfSearchResultsToShow = 5
    
    private var weather: Weather
    
    let locationName = Box<String>()
    let currentTemp = Box<String>()
    let weatherDescription = Box<String>()
    let feelsLikeTemp = Box<String>()
    let humidity = Box<String>()
    let icon = Box<UIImage>()
    let citySearchResult = Box<[String]>()
    
    init(weather: Weather) {
        self.weather = weather
    }
    
    func filterCities(withNamePrefix namePrefix: String) {
        if namePrefix.isEmpty {
            citySearchResult.value = []
            return
        }
        citySearchResult.value = weather.getCities(withNamePrefix: namePrefix, searchResultLimit: WeatherViewModel.countOfSearchResultsToShow)
    }
    
    func loadWeather(forCity cityName: String) {
        locationName.value = cityName
        updateToDataUnavailable()
        weather.update(forCity: cityName) { isSuccess in
            if isSuccess, self.weather.isAvailable {
                self.updateFromModel()
            }
            else {
                self.updateToDataUnavailable()
            }
        }
    }
    
    private func updateFromModel() {
        currentTemp.value = convertKelvinToCelsius(weather.temp)
        feelsLikeTemp.value = convertKelvinToCelsius(weather.feelsLikeTemp)
        humidity.value = String(format: "%.0f", weather.humidity) + "%"
        weatherDescription.value = weather.description.capitalized
        icon.value = UIImage(data: weather.iconData)
    }
    
    private func updateToDataUnavailable() {
        currentTemp.value = nil
        feelsLikeTemp.value = nil
        humidity.value = nil
        weatherDescription.value = nil
        icon.value = nil
    }
}
