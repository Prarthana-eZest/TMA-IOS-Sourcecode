//
//  NotificationCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 01/08/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak private var lblTitle: UILabel!

    @IBOutlet weak var icon: UIImageView!

    @IBOutlet weak private var notificationView: UIView!
    @IBOutlet weak private var lblNotificationCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(title: String, notificationCount: Int) {
        lblTitle.text = title
        notificationView.layer.cornerRadius = notificationView.frame.size.width * 0.5
        notificationView.layer.masksToBounds = true
        lblNotificationCount.text = "\(notificationCount)"
        notificationView.isHidden = true//!(notificationCount > 0)
    }

}
