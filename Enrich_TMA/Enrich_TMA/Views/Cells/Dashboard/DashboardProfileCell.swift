//
//  DashboardProfileCell.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 15/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

protocol DashboardHeaderCellDelegate: class {
    func locationUpdateAction()
    func locationDetailViewUpdate()
}

class DashboardProfileCell: UITableViewCell {
    
    
    @IBOutlet weak private var enableLocationView: UIView!
    @IBOutlet weak private var btnEnableLocation: UIButton!
    @IBOutlet weak var btnSelectALocation: UIButton!
    @IBOutlet weak private var locationNameView: UIStackView!
    @IBOutlet weak private var locationDetailsView: UIView!
    @IBOutlet weak private var locationDetailsbtnLocation: UIButton!
    @IBOutlet weak private var locationDetailsbtnSalonLocation: UIButton!
    
    weak var delegate: DashboardHeaderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        locationNameViewShowHide(status: false)
        locationDetailViewShowHide(status: true)
        enableLocationShowHide(status: true)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell() {
//        if  let dummy = UserDefaults.standard.value( LocationModule.Something.SalonParamModel.self, forKey: UserDefauiltsKeys.k_Key_SelectedSalon) {
//            self.btnSelectALocation.setTitle(dummy.current_city_area, for: .normal)
//            self.locationDetailsbtnLocation.setTitle(dummy.current_city_area, for: .normal)
//            let salonAddress = String(format: "%@ (%@)", dummy.salon_name ?? "", "\(dummy.distance.rounded(toPlaces: 2))" + " km")
//            self.locationDetailsbtnSalonLocation.setTitle(salonAddress, for: .normal)
//        } else {
            self.btnSelectALocation.setTitle("Select a Location", for: .normal)
       // }
    }
    
    @IBAction func actionEnableLocation(_ sender: UIButton) {
        delegate?.locationUpdateAction()
    }
    
    @IBAction func actionCloseEnableLocationView(_ sender: UIButton) {
        enableLocationShowHide(status: true)
    }
    
    @IBAction func actionCloseCurrentLocationView(_ sender: UIButton) {
        locationDetailViewShowHide(status: true)
        locationNameViewShowHide(status: false)
    }
    
    @IBAction func actionChangeLocation(_ sender: UIButton) {
    }
    
    @IBAction func actionChangeLocationDetailsView(_ sender: UIButton) {
    }
    
    @IBAction func actionPinnedEnrichNearYouLocationDetailsView(_ sender: UIButton) {
        delegate?.locationDetailViewUpdate()
    }
    
    func enableLocationShowHide(status: Bool) {
        enableLocationView.isHidden = status
    }
    
    func locationNameViewShowHide(status: Bool) {
        locationNameView.isHidden = status
    }
    
    func locationDetailViewShowHide(status: Bool) {
        locationDetailsView.isHidden = status
    }
    
}
