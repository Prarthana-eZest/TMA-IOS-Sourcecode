//
//  CalenderEventDetailsCell.swift
//  Enrich_TMA
//
//  Created by Harshal on 02/08/21.
//  Copyright © 2021 e-zest. All rights reserved.
//

import UIKit

class CalenderEventDetailsCell: UITableViewCell {
    
    @IBOutlet weak var eventColorView: UIView!
    @IBOutlet weak var lblEventName: UILabel!
    @IBOutlet weak var lblEventTime: UILabel!
    @IBOutlet weak var parentView: UIView!
    
    private var shadowLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        parentView.clipsToBounds = true
        parentView.layer.cornerRadius = 12
        parentView.layer.masksToBounds = false
        parentView.layer.shadowRadius = 12
        parentView.layer.shadowOpacity = 0.10
        parentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        parentView.layer.shadowColor = UIColor.gray.cgColor
        
        eventColorView.clipsToBounds = true
        eventColorView.layer.cornerRadius = 12
        eventColorView.layer.masksToBounds = false
        eventColorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    func configureCell(eventType: CalenderEvent, eventTitle: String, eventDate: String) {
        eventColorView.backgroundColor = eventType.eventColor
        lblEventName.text = eventTitle.capitalized
        lblEventTime.text = eventDate
    }
    
}

enum CalenderEvent {
    
    case shift, weekOff, leave, halfDay, publicHoliday
    
    var eventName: String {
        switch self {
        case .shift: return "Shift"
        case .weekOff: return "Week Off"
        case .leave: return "Leave"
        case .halfDay: return "Half Day"
        case .publicHoliday: return "Public Holiday"
        }
    }
    
    var eventColor: UIColor {
        switch self {
        case .shift: return UIColor(red: 0.12, green: 0.70, blue: 0.43, alpha: 1.00)
        case .weekOff: return UIColor(red: 0.52, green: 0.52, blue: 0.52, alpha: 1.00)
        case .leave: return UIColor(red: 1.00, green: 0.50, blue: 0.00, alpha: 1.00)
        case .halfDay: return UIColor(red: 1.00, green: 0.78, blue: 0.33, alpha: 1.00)
        case .publicHoliday: return UIColor(red: 0.87, green: 0.32, blue: 0.32, alpha: 1.00)
        }
    }
}
