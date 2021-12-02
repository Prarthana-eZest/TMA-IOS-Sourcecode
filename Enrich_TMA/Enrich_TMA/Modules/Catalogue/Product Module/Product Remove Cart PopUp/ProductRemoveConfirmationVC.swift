//
//  RemoveProductConfirmation.swift
//  EnrichSalon
//
//  Created by Harshal Patil on 24/07/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ProductRemoveConfirmationVC: UIViewController {
enum Status: Int {
        case close = 1
        case remove = 2
        case moveToWishList = 3
    }

    @IBOutlet weak private var productImage: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    var productImageURL: String = ""
    var onDoneBlock: ((Status) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        if !productImageURL.isEmpty {
            let url = URL(string: productImageURL)
            productImage.kf.setImage(with: url, placeholder: UIImage(named: "productDefault"), options: nil, progressBlock: nil, completionHandler: nil)
        }

        // Do any additional setup after loading the view.
    }
    @IBAction func actionClose(_ sender: UIButton) {
        onDoneBlock!(.close)
        self.dismiss(animated: false, completion: nil)

    }

    @IBAction func actionMoveToWishlist(_ sender: UIButton) {
        onDoneBlock!(.moveToWishList)
        self.dismiss(animated: false, completion: nil)

    }

    @IBAction func actionRemove(_ sender: UIButton) {
        onDoneBlock!(.remove)
        self.dismiss(animated: false, completion: nil)

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
