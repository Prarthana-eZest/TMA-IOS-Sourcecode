//
//  PickerView.swift
//  PickerData
//
//  Created by iOS on 10/01/22.
//

import UIKit

final class PickerView: UIView {

    @IBOutlet weak private var pickerView: MonthYearPickerView!
    @IBOutlet weak private var mainView: UIView!

    var selectedDate: ((Date) -> Void)?
    var selectedMonthYear: ((Date, String) -> Void)?
    
    private let dateFormatter = DateFormatter()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        pickerSetup()
        pickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        self.mainView.layer.cornerRadius = 6.0
    }

    private func commonInit() {}
    
    private func pickerSetup() {
        let minDate = "2021-01-02"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        pickerView.minimumDate = dateFormatter.date(from: minDate) ?? Date()
        
        let maxDate = "2022-12-31"
        if let maximumPickerDate = dateFormatter.date(from: maxDate) {
            pickerView.maximumDate = maximumPickerDate
        }
    }
    
    func setSelectedDate(_ date: Date) {
        pickerView.setDate(date, animated: true)
    }
    
    @objc func dateChanged(_ picker: MonthYearPickerView) {
        print("date changed: \(picker.date)")
    }
    
    //MARK:- IBActions
    
    @IBAction func selectButtonTapped() {
        selectedDate?(pickerView.date)
        selectedMonthYear?(pickerView.date, getFormattedMonthYear(date: pickerView.date))
        self.removeMe()
    }

    @IBAction func cancelButtonTapped() {
        self.removeMe()
    }
    
    private func getFormattedMonthYear(date: Date) -> String {
        dateFormatter.dateFormat = "MMMM yyyy"
        let strMonthYear = dateFormatter.string(from: date)
        return strMonthYear
    }
    
    // remove and add view
    
    func addMeOn(onView: UIView ) {
        if let window = UIWindow.key {
            self.alpha = 0.0
            self.frame = CGRect(x: 0, y: 0, width: onView.frame.width, height: onView.frame.height)

            UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) {
                self.alpha = 1.0
                window.addSubview(self)
            } completion: { _ in
            }
        }
    }

    func removeMe() {
        self.alpha = 1.0
        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) {
            self.alpha = 0.0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

}
