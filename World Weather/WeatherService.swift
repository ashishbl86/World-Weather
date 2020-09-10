//
//  WeatherService.swift
//  World Weather
//
//  Created by Ashish Bansal on 10/09/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import Foundation

protocol WeatherService {
    func getWeatherData(forCityId cityId: Int, _ responseHandler: @escaping (Result<[String:Any], Error>) -> Void)
    func getWeatherData(forLocation location: Location, _ responseHandler: @escaping (Result<[String:Any], Error>) -> Void)
    func getWeatherIcon(forIconName iconName: String, _ responseHandler: @escaping (Result<Data, Error>) -> Void)
}
