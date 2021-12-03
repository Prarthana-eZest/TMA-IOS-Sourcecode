//
//  ExtensionUITableView.swift
//  EnrichSalon
//
//  Created by Apple on 15/05/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//
// How to use
/*
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 if things.count == 0 {
 self.tableView.setEmptyMessage("My Message")
 } else {
 self.tableView.restore()
 }
 
 return things.count
 }
*/
import UIKit
extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: is_iPAD ? 24.0 : 16.0) ?? UIFont.systemFont(ofSize: is_iPAD ? 24.0 : 16.0)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
       // self.separatorStyle = .none;
    }

    func restore() {
        self.backgroundView = nil
        //self.separatorStyle = .singleLine
    }
}

extension UITableView {
    func lastIndexpath() -> IndexPath {
        let section = max(numberOfSections - 1, 0)
        let row = max(numberOfRows(inSection: section) - 1, 0)

        return IndexPath(row: row, section: section)
    }

}

extension UITableView {

    func scrollToBottom() {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.numberOfRows(inSection: self.numberOfSections - 1) - 1, section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func scrollToTop() {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

extension UITableView {

    /// Check if cell at the specific section and row is visible
    /// - Parameters:
    /// - section: an Int reprenseting a UITableView section
    /// - row: and Int representing a UITableView row
    /// - Returns: True if cell at section and row is visible, False otherwise
    func isCellVisible(section: Int, row: Int) -> Bool {
        guard let indexes = self.indexPathsForVisibleRows else {
            return false
        }
        return indexes.contains {$0.section == section && $0.row == row }
    }  }
