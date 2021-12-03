//
//  SortProductViewController.swift
//  EnrichSalon
//

import UIKit

// MARK: - SORT TYPES & NAMES
protocol SortSelectionDelegate: class {
    func SortSelectedIndex(index: Int)
    func CloseSortView()
}

enum SortIndexNames: Int {
    case Popularity = 0
    case PriccLowtoHigh
    case PriceHighttoLow
    case Newest

    func getName() -> String {
        switch self {
        case .Popularity:
            return "Popularity"
        case .PriccLowtoHigh:
            return "Price - Low to High"
        case .PriceHighttoLow:
            return "Price - Hight to Low"
        case .Newest:
            return "Newest First"
        }
    }
}

// MARK: - SORT CLASS
class SortProductViewController: UIViewController {

    @IBOutlet weak private var tblviewSort: UITableView!
    @IBOutlet weak private var imgViewObj: UIImageView!

    let sortPoints = [SortIndexNames.Popularity.getName(),
                      SortIndexNames.PriccLowtoHigh.getName(),
                      SortIndexNames.PriceHighttoLow.getName(),
                      SortIndexNames.Newest.getName()]

    var selectedIndex = -1
    weak var delegate: SortSelectionDelegate?

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        delegate?.CloseSortView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imgViewObj.alpha = 1
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SortProductViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortPoints.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath) as? SortCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        tableView.separatorStyle = .singleLine
        cell.lblTitle.text = self.sortPoints[indexPath.row]
        if indexPath.row == selectedIndex {
            cell.lblTitle.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: is_iPAD ? 24.0 : 16.0)
        }
        else {
            cell.lblTitle.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: is_iPAD ? 24.0 : 16.0)
        }
        if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
            tableView.separatorStyle = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return is_iPAD ? 60 : 45
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        selectedIndex = indexPath.row
        tblviewSort.reloadData()
        delegate?.SortSelectedIndex(index: selectedIndex)
        self.dismiss(animated: false, completion: nil)
    }

}
