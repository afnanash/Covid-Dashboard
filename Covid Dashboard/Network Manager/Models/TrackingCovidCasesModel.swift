//
//  TrakingCovidCadesModel.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 20/01/2022.
//

import Foundation

struct TrackingCovidCasesModel {
    
    struct Keys {
        static let countries = "countries"
    }
    
    var tarckingCases: [CovidCasesModel]?

    init(_ data:[String: Any]) {
        if let countries = data[Keys.countries] as? [String: Any] {
            var covidData: [CovidCasesModel] = []
            for country in countries {
                if let countryValueDic = country.value as? [String : Any] {
                    covidData.append(CovidCasesModel(countryValueDic))
                }
            }
            self.tarckingCases = covidData
        }
    }
}

struct CovidCasesModel {
    struct Keys {
        static let countryName = "name"
        static let covidCases = "today_confirmed"
        static let covidDeaths = "today_deaths"
    }
   
    let countryName: String?
    let covidCases: String?
    let covidDeaths: String?
  
    init(_ data:[String: Any]) {
        self.countryName = data[Keys.countryName] as? String
        self.covidCases =  String(data[Keys.covidCases] as? Int ?? .zero)
        self.covidDeaths = String(data[Keys.covidDeaths] as? Int ?? .zero)
    }
}
