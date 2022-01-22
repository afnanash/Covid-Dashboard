//
//  CovidNewsModel.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 20/01/2022.
//

import Foundation

struct CovidNewsModel: Decodable {
    let articles: [CovidNewsDataResponseModel]
}

struct CovidNewsDataResponseModel: Decodable {
  
    let title: String?
    let url: String?
    let imagePath: String?
    let author: String?

    enum CodingKeys: String, CodingKey {
        case title
        case author
        case url
        case imagePath = "urlToImage"
    }
}
