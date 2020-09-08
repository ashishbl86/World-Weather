//
//  Weather.swift
//  World Weather
//
//  Created by Ashish Bansal on 07/09/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import Foundation

struct Location {
    var latitude: Float
    var longitude: Float
}

class Weather {
    
    private (set) var temp = 0.0
    private (set) var feelsLikeTemp = 0.0
    private (set) var humidity = 0.0
    private (set) var isAvailable = false
    private (set) var iconData = Data()
    private (set) var description = ""
    
    private var weatherService: WeatherService
    private var sortedCitiesList = [String]()
    private var cityNameToId = [String:Int]()
    
    private func loadCityList() -> (cityNameToIdMap: [String:Int], sortedCitiesList: [String]) {
        let startTime = Date()
        var cities = [String:Int]()
        let cityListFileUrl = Bundle.main.url(forResource: "city.list", withExtension: "json")
        if let cityListFileUrl = cityListFileUrl,
            let fileData = try? Data(contentsOf: cityListFileUrl),
            let jsonData = try? JSONSerialization.jsonObject(with: fileData) {
            let cityInfoList = jsonData as! [Any]
            for cityInfo in cityInfoList {
                let cityDict = cityInfo as! [String:Any]
                let cityName = cityDict["name"] as! String
                if cityName.count > 1 {
                    let countryName = cityDict["country"] as! String
                    let cityId = cityDict["id"] as! Int
                    cities[cityName+","+countryName] = cityId
                }
            }
        }
        
        var cityList = cities.map { $0.key }
        cityList.sort()
        let elapsedTime = DateInterval(start: startTime, end: Date()).duration
        print("Time taken to load city list \(elapsedTime)")
        return (cities,cityList)
    }
    
    init(weatherService: WeatherService) {
        self.weatherService = weatherService
        let cityData = loadCityList()
        self.cityNameToId = cityData.cityNameToIdMap
        self.sortedCitiesList = cityData.sortedCitiesList
    }
    
    func getCities(withNamePrefix prefix: String, searchResultLimit: Int) -> [String] {
        let searchPredicate: (String) -> Bool = { cityName in
            let lowercasedCityName = cityName.lowercased()
            return lowercasedCityName.hasPrefix(prefix.lowercased())
        }
        
        if let firstIndex = sortedCitiesList.firstIndex(where: searchPredicate) {
            let lastIndex = sortedCitiesList.lastIndex(where: searchPredicate)!
            let searchLimitIndex = sortedCitiesList.index(firstIndex, offsetBy: searchResultLimit - 1, limitedBy: lastIndex) ?? lastIndex
            return [String](sortedCitiesList[firstIndex...searchLimitIndex])
        }
        return []
    }
    
    func update(forCity cityName: String, _ completionHandler: @escaping (Bool) -> Void) {
        weatherService.getWeatherData(forCityId: cityNameToId[cityName]!) { result in
            switch result {
            case .success(let weatherData):
                self.parseAndRetrieveWeatherData(from: weatherData, completionHandler)
                
            case .failure(_):
                self.isAvailable = false
                completionHandler(false)
            }
        }
    }
    
    private func parseAndRetrieveWeatherData(from jsonDict: [String: Any], _ completion: @escaping (Bool) -> Void) {
        guard let mainWeatherData = jsonDict["main"] as? [String:Double] else {
            self.isAvailable = false
            completion(false)
            return
        }
        
        guard let weatherData = jsonDict["weather"] as? [Any],
            let primaryWeatherData = weatherData.first as? [String:Any],
            let weatherIconName = primaryWeatherData["icon"] as? String,
            let weatherDescription = primaryWeatherData["description"] as? String else {
                self.isAvailable = false
                completion(false)
                return
        }
        
        guard let temp = mainWeatherData["temp"],
            let feelsLikeTemp = mainWeatherData["feels_like"],
            let humidity = mainWeatherData["humidity"] else {
                self.isAvailable = false
                completion(false)
                return
        }
        
        self.temp = temp
        self.feelsLikeTemp = feelsLikeTemp
        self.humidity = humidity
        self.description = weatherDescription
        
        weatherService.getWeatherIcon(forIconName: weatherIconName) { result in
            switch result {
            case .success(let iconData):
                self.iconData = iconData
                self.isAvailable = true
                completion(true)
                
            case .failure(_):
                completion(false)
            }
        }
    }
}
