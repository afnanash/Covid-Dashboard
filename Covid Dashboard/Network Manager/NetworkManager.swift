//
//  NetworkManager.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 20/01/2022.
//

import UIKit
import CoreLocation

class NetworkManager {
   
    typealias NetworkManagerAPIResponse<T: Decodable> = Swift.Result<T?, Error>
    typealias NetworkManagerNonDecodableAPIResponse<T> = Swift.Result<T?, Error>
    
    static private func setRequest(_ url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session =  URLSession(configuration: config)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            completion(data, response, error)
        })
        task.resume()
    }
    
    static func getDefaultCoordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 31.9654441, longitude: 35.898403)
    }
    
    static func getCountryInfo(_ countryName: String, _ completion: @escaping (NetworkManagerAPIResponse<CountryInfoModel>) -> Void) {
        let linkURL = "https://restcountries.com/v2/name/\(countryName)?fullText=true"
        if let url = URL(string: linkURL) {
            self.setRequest(url) { (data, _, error) in
                do {
                    guard let countryData = data else {
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(nil))
                        }
                        return
                    }
                    let jsonArrayResponse = try JSONDecoder().decode([CountryInfoModel].self, from: countryData)
                    for response in jsonArrayResponse {
                        completion(.success(response))
                    }
                }
                catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func getCovidNewsData(_ countryCode: String, _ completion: @escaping (NetworkManagerAPIResponse<CovidNewsModel>) -> Void) {
        let apiKey: String = "8bbbf26d1050477b87486946d5042e44"
        let linkURL = "https://newsapi.org/v2/top-headlines?country=\(countryCode)&category=health&apiKey=\(apiKey)"
        if let url = URL(string: linkURL) {
            self.setRequest(url) { (data, _, error) in
                do {
                    guard let covidNewsData = data else {
                        if let error = error {
                            completion(.failure(error))
                        }
                        else {
                            completion(.success(nil))
                        }
                        return
                    }
                    let jsonResponse = try JSONDecoder().decode(CovidNewsModel.self, from: covidNewsData)
                    completion(.success(jsonResponse))
                }
                catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func getCovidTrakingData(_ date: String,
                                    _ completion: @escaping (NetworkManagerNonDecodableAPIResponse<TrackingCovidCasesModel>) -> Void) {
        let linkURL = "https://api.covid19tracking.narrativa.com/api/\(date)"
        if let url = URL(string: linkURL) {
            self.setRequest(url, completion: { (data, _ , error) in
                do {
                    guard let trakingData = data else {
                        if let error = error {
                            completion(.failure(error))
                        }
                        else {
                            completion(.success(nil))
                        }
                        return
                    }
                    let jsonResponse = try JSONSerialization.jsonObject(with: trakingData, options: []) as? [String: Any]
                    if let covidData = jsonResponse?["dates"] as? [String: Any],
                       let currentDateConditions = covidData[date] as? [String: Any] {
                        completion(.success(TrackingCovidCasesModel(currentDateConditions)))
                    }
                    else {
                        completion(.success(TrackingCovidCasesModel([:])))
                    }
                }
                catch let error {
                    completion(.failure(error))
                }
            })
        }
    }
    
    static func getCountryCoordinates(_ countryName: String,
                                      _ completion: @escaping (NetworkManagerNonDecodableAPIResponse<LocationsDataModel>) -> Void) {
        let geocoder = CLGeocoder()
        let name = countryName.trimmingCharacters(in: .whitespaces)
        geocoder.geocodeAddressString(name) { data, error in
            guard let locations = data?.first, let location = locations.location else {
                completion(.success(nil))
                return
            }
            completion(.success(LocationsDataModel(coordinates: location.coordinate)))
        }
    }
    
    static func getSelectedLoctionInfo(_ location: CLLocation, completion: @escaping (NetworkManagerAPIResponse<CountryInfoModel>) -> Void) {
        let reverseGeocoder = CLGeocoder()
        let englishLocale = Locale(identifier: "en_US")
        reverseGeocoder.reverseGeocodeLocation(location, preferredLocale: englishLocale as Locale) { placemarks, error in
            guard let placemark = placemarks?.last, let country = placemark.country else {
                completion(.success(nil))
                return
            }
            self.getCountryInfo(country) { response in
                switch response {
                case .success(let dataModel):
                    completion(.success(dataModel))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func loadImage(imageURL: String, completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            if let url = URL(string: imageURL), let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
            else {
                completion(nil)
            }
        }
    }
    
}
