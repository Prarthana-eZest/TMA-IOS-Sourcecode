//
//  JabCardServiceHeaderCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/11/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol JobCardDelegate: class {
    func actionGenericForm()
    func actionSpecificForm()
}

class JabCardServiceHeaderCell: UITableViewCell {

    @IBOutlet weak private var lblServiceName: UILabel!
    @IBOutlet weak private var lblServiceDescription: UILabel!
    @IBOutlet weak private var lblTotalTime: UILabel!
    @IBOutlet weak private var genericFormButtonStackView: UIStackView!
    @IBOutlet weak private var specificFormButtonStackView: UIStackView!
    @IBOutlet weak private var lblNotes: UILabel!
    @IBOutlet weak private var notesView: UIView!
    @IBOutlet weak private var dependentIcon: UIImageView!
    

    weak var delegate: JobCardDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(serviceName: String, serviceDescription: String,
                       totalTime: String, isConsultationRequired: Bool,
                       isGenericFormFilled: Bool, notes: String,
                       isDependentService: Bool) {
        lblServiceName.text = serviceName
        lblServiceDescription.text = serviceDescription
        lblTotalTime.text = totalTime
        specificFormButtonStackView.isHidden = !isConsultationRequired
        genericFormButtonStackView.isHidden = (isGenericFormFilled || !isConsultationRequired)
        lblNotes.text = "Note - \(notes)"
        notesView.isHidden = notes.isEmpty
        dependentIcon.isHidden = !isDependentService
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func actionGenericForm(_ sender: UIButton) {
        self.delegate?.actionGenericForm()
    }

    @IBAction func actionSpecificForm(_ sender: UIButton) {
        self.delegate?.actionSpecificForm()
    }

}

struct ServiceDescriptionModel {
    let title: String
    let pointSeparation: Bool
    let data: String
}

struct RecommendationsModel {
    let products: [Any]
    let valuePackes: [Any]
}
