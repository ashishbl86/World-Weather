//
//  WeatherService.swift
//  World Weather
//
//  Created by Ashish Bansal on 07/09/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import Foundation

class WeatherService {
    
    static var shared = WeatherService()
    private let apiKeyEnvVarName = "OpenWeatherApiKey"
    private var weatherApiKey: String!
    let weatherDataQueryUrlComponentsTemplate: URLComponents
    let weatherIconQueryUrlComponentsTemplate: URLComponents

    private init() {
        weatherApiKey = ProcessInfo.processInfo.environment[apiKeyEnvVarName]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        urlComponents.queryItems = [URLQueryItem(name: "appid", value: weatherApiKey ?? "")]
        weatherDataQueryUrlComponentsTemplate = urlComponents
        
        urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "openweathermap.org"
        urlComponents.path = "/img/wn/<IconName>@2x.png"
        weatherIconQueryUrlComponentsTemplate = urlComponents
        
        if weatherApiKey == nil {
            fatalError("Open Weather API key not found. Expecting to be set in environment variable '\(apiKeyEnvVarName)'")
        }
    }
    
    func getWeatherData(forCityId cityId: Int, _ responseHandler: @escaping (Result<[String:Any], Error>) -> Void) {
        var cityWeatherQueryUrlComponents = weatherDataQueryUrlComponentsTemplate
        cityWeatherQueryUrlComponents.queryItems?.append(contentsOf: [URLQueryItem(name: "id", value: "\(cityId)")])
        getWeatherData(withQueryUrl: cityWeatherQueryUrlComponents.url!, responseHandler)
    }
    
    func getWeatherData(forLocation location: Location, _ responseHandler: @escaping (Result<[String:Any], Error>) -> Void) {
        var weatherQueryUrlComponents = weatherDataQueryUrlComponentsTemplate
            weatherQueryUrlComponents.queryItems?.append(contentsOf: [
            URLQueryItem(name: "lat", value: "\(location.latitude)"),
            URLQueryItem(name: "lon", value: "\(location.longitude)")
        ])
        
        getWeatherData(withQueryUrl: weatherQueryUrlComponents.url!, responseHandler)
    }
    
    private func getWeatherData(withQueryUrl queryUrl: URL, _ responseHandler: @escaping (Result<[String:Any], Error>) -> Void) {
        let weatherTask = URLSession.shared.dataTask(with: queryUrl) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data!), let jsonDict = jsonObject as? [String:Any] {
                    responseHandler(.success(jsonDict))
                    return
                }
            }
            responseHandler(.failure(error ?? NSError(domain: "Network Error", code: 0, userInfo: [NSLocalizedDescriptionKey : "Network call unsuccessful to fetch weather data"])))
        }
        
        weatherTask.resume()
    }
    
    func getWeatherIcon(forIconName iconName: String, _ responseHandler: @escaping (Result<Data, Error>) -> Void) {
        var weatherIconQueryUrlComponents = weatherIconQueryUrlComponentsTemplate
        weatherIconQueryUrlComponents.path = weatherIconQueryUrlComponents.path.replacingOccurrences(of: "<IconName>", with: iconName)
        let weatherIconTask = URLSession.shared.dataTask(with: weatherIconQueryUrlComponents.url!) { (imageData, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                responseHandler(.success(imageData!))
                return
            }
            responseHandler(.failure(error ?? NSError(domain: "Network Error", code: 0, userInfo: [NSLocalizedDescriptionKey : "Network call unsuccessful to fetch icon image"])))
        }
        
        weatherIconTask.resume()
    }
}
