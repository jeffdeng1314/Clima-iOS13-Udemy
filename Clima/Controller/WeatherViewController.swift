//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!

    @IBOutlet weak var searchFieldText: UITextField!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate must come before any of these, so we won't run into the 'Delegate must respond to locationManager:didUpdateLocations:' error
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // setting the current view controller as the textField delegate, this way we ensure the view controller is being notified by the text field.
        // Here say that the text field should report back to the controller
        // When user interacts with text field, then text field will notify our view controller on what's happening
        // The idea here is that the text field can communicate what's going on and the way we can ensure that the view controller notified by the text field is by setting the view controller as the delegate
        searchFieldText.delegate = self
        weatherManager.delegate = self
    }
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: String(lat), longitude: String(lon))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}


// MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchFieldText.endEditing(true)
        print(searchFieldText.text!)
    }
    
    
    // hides keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchFieldText.endEditing(true)
        print(searchFieldText.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // clear text field
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let cityName = searchFieldText.text {
            weatherManager.fetchWeather(cityName: cityName)
        }
        searchFieldText.text = ""
    }
}


// MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
   
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }

    func didFailedWithError(error: Error) {
        print(error)
    }
    
    
}
