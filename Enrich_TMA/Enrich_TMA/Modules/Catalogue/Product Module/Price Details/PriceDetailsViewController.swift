//
//  PriceDetailsViewController.swift
//  EnrichSalon
//

import UIKit

class PriceDetailsViewController: UIViewController {

    // private
    @IBOutlet private weak var imgViewObj: UIImageView!
    @IBOutlet private weak var tableView: UITableView!

    // public
    var arrData = [ProductCartAddOnsModel]()
    var onDoneBlock: ((Bool) -> Void)?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imgViewObj.alpha = 1
    }

    // MARK: - ActionClose
    @IBAction func actionClose(_ sender: UIButton) {
        onDoneBlock!(true)
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension PriceDetailsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell: PriceDetailsCell = tableView.dequeueReusableCell(withIdentifier: "PriceDetailsCell", for: indexPath) as? PriceDetailsCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none

        cell.configureCell(productModel: arrData[indexPath.row])
        if (indexPath.row == arrData.count - 1) {

            cell.lblProductName.font = UIFont(name: FontName.NotoSansSemiBold.rawValue, size: is_iPAD ? 19.0 : 16.0)
            cell.lblPrice.font = UIFont(name: FontName.NotoSansSemiBold.rawValue, size: is_iPAD ? 19.0 : 16.0)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return is_iPAD ? 60 : 45
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }

}
