//
//  CovidNewsCell.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 21/01/2022.
//

import UIKit

class CovidNewsCell: UITableViewCell {
    
    @IBOutlet weak var newsLogo: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func fill(article: CovidNewsDataResponseModel) {
        self.authorLabel.text = article.author
        self.titleLabel.text = article.title
        if let imageURL = article.imagePath {
            NetworkManager.loadImage(imageURL: imageURL, completion: { image  in
                self.newsLogo.image = image
            })
        }
    }
}
