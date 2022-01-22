//
//  CovidNewsController.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 21/01/2022.
//

import UIKit

class CovidNewsController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var covidDeathsLabel: UILabel!
    @IBOutlet weak var covidCasesLabel: UILabel!
    
    var articles : [CovidNewsDataResponseModel]?
    var tarckingCovidCases: CovidCasesModel?
    var countryInfo: CountryInfoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Covid News"
        setCountryInfo()
        setTableView()
    }
    
    private func setTableView() {
        let nib = UINib(nibName: "CovidNewsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CovidNewsCell")
        tableView.reloadData()
    }
    
    private func setCountryInfo() {
        guard let info = countryInfo, let covidInfo = tarckingCovidCases else {
            return
        }
        countryLabel.text = info.countryName
        covidCasesLabel.text = covidInfo.covidCases
        covidDeathsLabel.text = covidInfo.covidDeaths
        if let flag = info.countryFlag, let imageURL = flag.png {
            NetworkManager.loadImage(imageURL: imageURL, completion: { image  in
                self.countryFlag.image = image
            })
        }
    }
}

extension CovidNewsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let articles = articles {
            let selectedArticle = articles[indexPath.row]
            if let stringURL = selectedArticle.url, let url = URL(string: stringURL) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let articles = articles, !articles.isEmpty {
            return articles.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let articles = articles, !articles.isEmpty {
            let selectedArticle = articles[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CovidNewsCell", for: indexPath) as! CovidNewsCell
            cell.fill(article: selectedArticle)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoInfoCell", for: indexPath)
            cell.textLabel?.text = "Sorry No Info for Today"
            return cell
        }
    }
}
