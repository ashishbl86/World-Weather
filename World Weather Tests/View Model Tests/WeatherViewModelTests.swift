//
//  WeatherViewModelTests.swift
//  World Weather Tests
//
//  Created by Ashish Bansal on 10/09/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import XCTest
@testable import World_Weather

class StubWeatherService: WeatherService {
    func getWeatherData(forCityId cityId: Int, _ responseHandler: @escaping (Result<[String : Any], Error>) -> Void) {
        XCTFail("Not expected to be invoked")
    }
    
    func getWeatherData(forLocation location: Location, _ responseHandler: @escaping (Result<[String : Any], Error>) -> Void) {
        XCTFail("Not expected to be invoked")
    }
    
    func getWeatherIcon(forIconName iconName: String, _ responseHandler: @escaping (Result<Data, Error>) -> Void) {
        XCTFail("Not expected to be invoked")
    }
}

class StubWeather: Weather {
    
    var _temp = 313.15
    var _feelsLikeTemp = 315.15
    var _humidity = 30.5
    
    init() {
        super.init(weatherService: StubWeatherService())
    }

    override func getCities(withNamePrefix prefix: String, searchResultLimit: Int) -> [String] {
        if prefix == "A" {
            return ["aa", "aab", "aac"]
        }
        return []
    }

    override var temp: Double {
        _temp
    }
    
    override var feelsLikeTemp: Double {
        _feelsLikeTemp
    }
    
    override var humidity: Double {
        _humidity
    }
    
    override var isAvailable: Bool {
        true
    }
    
    override func update(forCity cityName: String, _ completionHandler: @escaping (Bool) -> Void) {
        if cityName == "A" {
            completionHandler(true)
        }
        else {
            completionHandler(false)
        }
    }
}

class WeatherViewModelTests: XCTestCase {
        
    func testDefaultState_ValuesAreNil() {
        let weatherViewModel = WeatherViewModel(weather: StubWeather())
        XCTAssertNil(weatherViewModel.locationName.value)
        XCTAssertNil(weatherViewModel.currentTemp.value)
        XCTAssertNil(weatherViewModel.weatherDescription.value)
        XCTAssertNil(weatherViewModel.feelsLikeTemp.value)
        XCTAssertNil(weatherViewModel.humidity.value)
        XCTAssertNil(weatherViewModel.icon.value)
        XCTAssertNil(weatherViewModel.citySearchResult.value)
    }
    
    func testFilterCities_InputValueIsBlank_EmptyResult() {
        let weatherViewModel = WeatherViewModel(weather: StubWeather())
        weatherViewModel.filterCities(withNamePrefix: "")
        XCTAssertTrue(weatherViewModel.citySearchResult.value?.isEmpty ?? false)
    }
    
    func testFilterCities_PredefinedPrefix_ValuesAsPerStub() {
        let weatherViewModel = WeatherViewModel(weather: StubWeather())
        weatherViewModel.filterCities(withNamePrefix: "A")
        XCTAssertEqual(weatherViewModel.citySearchResult.value, ["aa", "aab", "aac"])
    }
    
    func testLoadWeather_PredefinedCityName_ValuesAsPerStub() {
        let currentTempExpectation = expectation(description: "Current temp value expectation")
        let feelsLikeTempExpectation = expectation(description: "Feels like temp value expectation")
        let humidityExpectation = expectation(description: "Humidity value expectation")
        
        let currentTempListener: (String?) -> Void = { value in
            if value == "40.0°C" {
                currentTempExpectation.fulfill()
            }
        }
        
        let feelsLikeTempListener: (String?) -> Void = { value in
            if value == "42.0°C" {
                feelsLikeTempExpectation.fulfill()
            }
        }
        
        let humidityListener: (String?) -> Void = { value in
            if value == "30%" {
                humidityExpectation.fulfill()
            }
        }
        
        let weatherViewModel = WeatherViewModel(weather: StubWeather())
        weatherViewModel.currentTemp.bind(listener: currentTempListener)
        weatherViewModel.feelsLikeTemp.bind(listener: feelsLikeTempListener)
        weatherViewModel.humidity.bind(listener: humidityListener)
        weatherViewModel.loadWeather(forCity: "A")
        wait(for: [currentTempExpectation, feelsLikeTempExpectation, humidityExpectation], timeout: 1.0)
    }
}
