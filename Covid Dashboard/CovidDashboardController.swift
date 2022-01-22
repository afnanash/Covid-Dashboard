//
//  CovidDashboardController.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 20/01/2022.
//

import CoreLocation
import MapKit
import UIKit

class CovidDashboardController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var locationManager: CLLocationManager?
    
    var articles : [CovidNewsDataResponseModel]?
    var tarckingCovidCases: CovidCasesModel?
    var countryInfo: CountryInfoModel?
    var updatedDate: String? {
        didSet {
            getCovidTrakingData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationItem()
        setLocationManager()
        mapView.delegate = self
        mapView.showsUserLocation = true
        updatedDate = self.formatDate(Date())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let sourceController = segue.destination as? CovidNewsController {
            sourceController.articles = self.articles
            sourceController.countryInfo = self.countryInfo
            sourceController.tarckingCovidCases = self.tarckingCovidCases
        }
    }
    
    private func setLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.delegate = self
    }
    
    private func configureNavigationItem() {
        var items: [UIBarButtonItem] = []
        items.append(UIBarButtonItem(image: UIImage(named: "Filter"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(filterCovidDate)))
        navigationItem.rightBarButtonItems = items
        navigationItem.title = "Covid Dashboard"
    }
    
    @objc private func filterCovidDate() {
        self.performSegue(withIdentifier: "showFilterDate", sender: self)
    }
    
    @IBAction func unwindToCovidMap(unwindSegue: UIStoryboardSegue) {
        if let sourceController = unwindSegue.source as? FilterCovidDatesController {
            self.updatedDate = sourceController.newDate
        }
    }
}

extension CovidDashboardController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager?.startUpdatingLocation()
        case.notDetermined:
            self.locationManager?.requestWhenInUseAuthorization()
        default:
            let coordinates = NetworkManager.getDefaultCoordinates()
            self.setRegion(latitude: coordinates.latitude, and: coordinates.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        self.locationManager?.stopUpdatingLocation()
        self.locationManager = nil
        self.setRegion(latitude: locationValue.latitude, and: locationValue.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
#if DEBUG
        debugPrint("\(self.self): \(#function) line: \(#line).  \(error.localizedDescription)")
#endif
        let coordinates = NetworkManager.getDefaultCoordinates()
        self.setRegion(latitude: coordinates.latitude, and: coordinates.longitude)
    }
}

extension CovidDashboardController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            let button = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = button
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let coordinate = view.annotation?.coordinate {
            let cLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.showIndicatorView()
            NetworkManager.getSelectedLoctionInfo(cLLocation) { [weak self] response in
                self?.hideIndicatorView()
                switch response {
                case .success(let dataModel):
                    guard let countryInfo = dataModel else {
                        self?.showAlert("No Covid News")
                        return
                    }
                    self?.getCovidNewsDataBasedOn(countryInfo: countryInfo)
                case .failure(let error):
                    self?.showAlert(error.localizedDescription)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverLay = overlay as? MKCircle {
            let circleRederer = MKCircleRenderer(overlay: circleOverLay)
            circleRederer.fillColor = .red
            circleRederer.strokeColor = .red
            circleRederer.alpha = 0.5
            return circleRederer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension CovidDashboardController {
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func createTrackingDataPinAnnotation(atLocation point: CLLocationCoordinate2D, title: String, subTitle: String) {
        let trackingDataPinAnnotation = MKPointAnnotation()
        trackingDataPinAnnotation.coordinate = point
        trackingDataPinAnnotation.title = title
        trackingDataPinAnnotation.subtitle = subTitle
        addCirclesWith(coordinate: point)
        mapView.addAnnotation(trackingDataPinAnnotation)
    }
    
    private func addCirclesWith(coordinate: CLLocationCoordinate2D) {
        let circle = MKCircle(center: coordinate, radius: 100000)
        mapView.addOverlay(circle)
    }
    
    private func showIndicatorView() {
        DispatchQueue.main.async {
            self.indicatorView.startAnimating()
            self.mapView.isUserInteractionEnabled = false
        }
    }

    private func hideIndicatorView() {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
            self.mapView.isUserInteractionEnabled = true
        }
    }
    
    private func showAlert(_ msg: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: msg, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func setRegion(latitude: CLLocationDegrees, and longitude: CLLocationDegrees) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension CovidDashboardController {
    
    private func getCovidTrakingData() {
        guard let date = updatedDate else {
            return
        }
        self.showIndicatorView()
        NetworkManager.getCovidTrakingData(date) { [weak self] response in
            self?.hideIndicatorView()
            switch response {
            case .success(let dataModel):
                guard let model = dataModel ,let cases = model.tarckingCases else {
                    return
                }
                self?.showUpdatedCovidInfo(cases)
            case .failure(let error):
                self?.showAlert(error.localizedDescription)
            }
        }
    }
    
    private func getCovidNewsDataBasedOn(countryInfo: CountryInfoModel) {
        guard let countryCode = countryInfo.countryCode else {
            self.showAlert("No Location Data")
            return
        }
        self.showIndicatorView()
        NetworkManager.getCovidNewsData(countryCode) { [weak self] response in
            self?.hideIndicatorView()
            switch response {
            case .success(let dataModel):
                guard let model = dataModel else {
                    return
                }
                DispatchQueue.main.async {
                    self?.showCovidNews(model.articles, countryInfo: countryInfo)
                }
            case .failure(let error):
                self?.showAlert(error.localizedDescription)
            }
        }
    }
    
    private func showCovidNews(_ articles: [CovidNewsDataResponseModel] , countryInfo: CountryInfoModel) {
        self.articles = articles
        self.countryInfo = countryInfo
        self.performSegue(withIdentifier: "showCovidNews", sender: self)
    }
    
    private func showUpdatedCovidInfo(_ tarckingCovidCases: [CovidCasesModel]) {
        self.showIndicatorView()
        for data in tarckingCovidCases {
            guard let countryName = data.countryName, let covidCases = data.covidCases, let covidDeaths = data.covidDeaths else {
                return
            }
            NetworkManager.getCountryCoordinates(countryName) { [weak self] response in
                self?.hideIndicatorView()
                switch response {
                case .success(let dataModel):
                    guard let coordinates = dataModel?.coordinates else {
                        return
                    }
                    self?.tarckingCovidCases = data
                    self?.createTrackingDataPinAnnotation(atLocation: coordinates,
                                                          title: "Cases: \(covidCases)",
                                                          subTitle: "Deaths: \(covidDeaths)")
                case .failure(let error):
                    self?.showAlert(error.localizedDescription)
                }
            }
        }
    }
}
