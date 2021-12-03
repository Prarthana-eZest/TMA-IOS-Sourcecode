//
//  SubCategoryListingVC.swift
//  EnrichSalon
//
//  Created by Apple on 06/12/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class SubCategoryVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    var onDoneBlock: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        addSOSButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

    }

    func addSOSButton() {
        guard let sosImg = UIImage(named: "SOS") else {
            return
        }
        let sosButton = UIBarButtonItem(image: sosImg, style: .plain, target: self, action: #selector(didTapSOSButton))
        sosButton.tintColor = UIColor.black
        navigationItem.title = ""
        if showSOS {
            navigationItem.rightBarButtonItems = [sosButton]
        }
    }

    @objc func didTapSOSButton() {
        SOSFactory.shared.raiseSOSRequest()
    }

    // MARK: - IBAction
    @IBAction func actionClose(_ sender: Any) {
        onDoneBlock!(false)
        self.dismiss(animated: false, completion: nil)

    }
    // MARK: - Other Functions
    func setConfig(imageURL: String, title: String) {
        lblCategory.text = title
        if !imageURL.isEmpty {
            let url = URL(string: imageURL )
            imgView.kf.setImage(with: url, placeholder: UIImage(named: "categoryPlaceholderImg"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
