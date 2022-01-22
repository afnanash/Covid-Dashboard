//
//  CountryCodeModel.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 20/01/2022.
//

import Foundation

struct CountryInfoModel: Decodable {
    let countryName: String?
    let countryCode: String?
    let countryFlag: CountryFlagsModel?
   
    enum CodingKeys: String, CodingKey {
        case countryName = "name"
        case countryCode = "alpha2Code"
        case countryFlag = "flags"
    }
}

struct CountryFlagsModel: Decodable {
    let svg: String?
    let png: String?
}
