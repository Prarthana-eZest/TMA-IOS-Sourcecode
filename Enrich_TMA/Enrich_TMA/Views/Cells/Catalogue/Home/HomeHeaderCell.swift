//
//  SelectLocationHeaderCell.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 17/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

protocol HomeHeaderCellDelegate: class {
    func bookAppointmentAction()
    func locationUpdateAction()
    func locationDetailViewUpdate()

}
class HomeHeaderCell: UITableViewCell {

    @IBOutlet weak private var backgroundImage: UIImageView!
    @IBOutlet weak private var lblTitle: UILabel!
    @IBOutlet weak private var lblDescription: UILabel!

    weak var delegate: HomeHeaderCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.backgroundImage.setGradientToImageView()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionBookAppointment(_ sender: UIButton) {
        delegate?.bookAppointmentAction()
    }

}
