//
//  FilterCovidDatesController.swift
//  Covid Dashboard
//
//  Created by Afnan Ashour on 21/01/2022.
//

import UIKit

class FilterCovidDatesController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    
    var newDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Update Date"
        newDate = formatDate(self.datePicker.date)
        textField.text = self.newDate
        datePicker.preferredDatePickerStyle = .wheels
    }
    
    @IBAction func didUpdateDate(_ sender: Any) {
        newDate = formatDate(datePicker.date)
        textField.text = newDate
    }
    
    @IBAction func didConfirmDate(_ sender: Any) {
        self.performSegue(withIdentifier: "backToCovidMap", sender: self)
    }
}

extension FilterCovidDatesController {
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
