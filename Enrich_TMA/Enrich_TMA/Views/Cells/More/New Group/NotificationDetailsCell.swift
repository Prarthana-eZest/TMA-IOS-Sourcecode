//
//  NotificationDetailsCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 23/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class NotificationDetailsCell: UITableViewCell {
    @IBOutlet weak private var lblTypeOfReminder: UILabel!
    @IBOutlet weak private var lblReminderTitle: UILabel!
    @IBOutlet weak private var btnDelete: UIButton!
    @IBOutlet weak private var lblNotifcationDesicription: UILabel!
    @IBOutlet weak private var lblLocationForWithTime: UILabel!
    @IBOutlet weak private var lblTimeAgo: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblLocationForWithTime.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureNotification(model: Notifications.MyNotificationList.MyNotificationListItems ) {
        lblTypeOfReminder.text = model.module?.uppercased() ?? ""
        lblReminderTitle.text = model.subject ?? ""
        lblNotifcationDesicription.text = model.message ?? ""
        if let orderDate = model.created_at, !orderDate.isEmpty {
            let date = orderDate.getFormattedDate()
            lblTimeAgo.text = date.timeAgoSinceDate(date: date as NSDate, numericDates: true)
        }
    }
}
