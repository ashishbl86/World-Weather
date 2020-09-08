//
//  ViewController.swift
//  World Weather
//
//  Created by Ashish Bansal on 06/09/20.
//  Copyright © 2020 Ashish Bansal. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UITextFieldDelegate {
    
    private var weatherViewModel: WeatherViewModel!
    private var searchTextDecoratorHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var feelsLikeTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var citySearchField: UITextField!
    @IBOutlet weak var citySearchResultsContainerView: UIStackView!
    
    private var citySearchResultList = [String]() {
        didSet {
            updateCitySearchResultViews()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func updateCitySearchResultViews() {
        let countOfCitiesInSearchResult = citySearchResultList.count
        let labelViews = citySearchResultsContainerView.arrangedSubviews
        let viewsToShow = labelViews[0 ..< countOfCitiesInSearchResult]
        for (index,view) in viewsToShow.enumerated() {
            view.isHidden = false
            let labelView = view as! UILabel
            labelView.text = citySearchResultList[index]
        }
        
        let countOfViewsToHide = WeatherViewModel.countOfSearchResultsToShow - countOfCitiesInSearchResult
        if countOfViewsToHide > 0 {
            let indexOfFirstViewToHide = WeatherViewModel.countOfSearchResultsToShow - countOfViewsToHide
            let viewsToHide = labelViews[indexOfFirstViewToHide ..< labelViews.endIndex]
            viewsToHide.forEach { $0.isHidden = true }
        }
    }
    
    private func setup() {
        weatherViewModel = WeatherViewModel(weatherService: WeatherService.shared)
    }

    private func bindViewsToViewModel() {
        weatherViewModel.locationName.bind { locationName in
            DispatchQueue.main.async {
                self.locationLabel.text = locationName
            }
        }
        
        weatherViewModel.currentTemp.bind { currentTemp in
            DispatchQueue.main.async {
                self.tempLabel.text = currentTemp
            }
        }
        
        weatherViewModel.weatherDescription.bind { weatherDescription in
            DispatchQueue.main.async {
                self.weatherDescriptionLabel.text = weatherDescription
            }
        }
        
        weatherViewModel.feelsLikeTemp.bind { feelsLikeTemp in
            DispatchQueue.main.async {
                self.feelsLikeTempLabel.text = feelsLikeTemp
            }
        }
        
        weatherViewModel.humidity.bind { humidity in
            DispatchQueue.main.async {
                self.humidityLabel.text = humidity
            }
        }
        
        weatherViewModel.icon.bind { image in
            DispatchQueue.main.async {
                self.weatherIconView.image = image
            }
        }
        
        weatherViewModel.citySearchResult.bind { citiesList in
            self.citySearchResultList = citiesList ?? []
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !searchTextDecoratorHeightConstraint.isActive {
            NSLayoutConstraint.activate([searchTextDecoratorHeightConstraint])
        }
    }
    
    private func decorateCityInputTextField() {
        let magnifyingGlassImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        magnifyingGlassImageView.translatesAutoresizingMaskIntoConstraints = false
        magnifyingGlassImageView.tintColor = .systemGray
        
        let searchFieldDecoratorView = UIView()
        searchFieldDecoratorView.translatesAutoresizingMaskIntoConstraints = false
        searchFieldDecoratorView.addSubview(magnifyingGlassImageView)
        
        NSLayoutConstraint.activate([
            searchFieldDecoratorView.widthAnchor.constraint(equalTo: searchFieldDecoratorView.heightAnchor),
            searchFieldDecoratorView.centerXAnchor.constraint(equalTo: magnifyingGlassImageView.centerXAnchor),
            searchFieldDecoratorView.centerYAnchor.constraint(equalTo: magnifyingGlassImageView.centerYAnchor),
            magnifyingGlassImageView.widthAnchor.constraint(equalTo: magnifyingGlassImageView.heightAnchor)
        ])
        
        searchTextDecoratorHeightConstraint = searchFieldDecoratorView.heightAnchor.constraint(equalToConstant: citySearchField.frame.height)
        citySearchField.leftView = searchFieldDecoratorView
        citySearchField.leftViewMode = .always
    }
    
    @objc private func doneWithKeyboard() {
        citySearchField.resignFirstResponder()
        citySearchField.text = nil
        citySearchResultList = []
    }
    
    @objc private func searchLabelTapPerformed(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedLabel = tapGestureRecognizer.view as! UILabel
        print("Tapped city: \(tappedLabel.text!)")
        citySearchField.resignFirstResponder()
        citySearchField.text = tappedLabel.text
        citySearchResultList = []
        weatherViewModel.loadWeather(forCity: tappedLabel.text!)
    }
    
    private func createLabelViewsForSearchResult() {
        for index in 0 ..< WeatherViewModel.countOfSearchResultsToShow {
            let labelView = UILabel()
            labelView.translatesAutoresizingMaskIntoConstraints = false
            labelView.backgroundColor = view.backgroundColor
            labelView.textColor = .white
            labelView.font = UIFont.preferredFont(forTextStyle: .body)
            citySearchResultsContainerView.insertArrangedSubview(labelView, at: index)
            labelView.isHidden = true
            NSLayoutConstraint.activate([labelView.heightAnchor.constraint(equalToConstant: 30)])
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchLabelTapPerformed(_:)))
            labelView.addGestureRecognizer(tapGestureRecognizer)
            labelView.isUserInteractionEnabled = true
        }
    }
    
    private func configureKeyboardToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        let item1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let item2 = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneWithKeyboard))
        toolbar.setItems([item1,item2], animated: false)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        citySearchField.inputAccessoryView = toolbar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewsToViewModel()
        decorateCityInputTextField()
        configureKeyboardToolbar()
        createLabelViewsForSearchResult()
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: citySearchField, queue: nil) { _ in
            self.weatherViewModel.filterCities(withNamePrefix: self.citySearchField.text!)
        }
    }
}

