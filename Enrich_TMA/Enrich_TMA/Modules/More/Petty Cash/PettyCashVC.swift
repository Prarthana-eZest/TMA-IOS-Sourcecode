//
//  PettyCashVC.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 11/10/19.
//  Copyright © 2019 e-zest. All rights reserved.
//

import UIKit

class PettyCashVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let sections:[PettyCashCellModel] = [PettyCashCellModel(title: "Date & time:", value: "Tue, 5 Apr | 12:10 pm", imageURL: "", canEdit: false),
                                         PettyCashCellModel(title: "Purpose", value: "Tue, 5 Apr | 12:10 pm", imageURL: "", canEdit: false),
                                         PettyCashCellModel(title: "Amount", value: "2380", imageURL: "", canEdit: false),
                                         PettyCashCellModel(title: "Attachement", value: "", imageURL: "", canEdit: false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.register(UINib(nibName: "PettyCashCell", bundle: nil), forCellReuseIdentifier: "PettyCashCell")
        tableView.register(UINib(nibName: "PettyCashAttachementCell", bundle: nil), forCellReuseIdentifier: "PettyCashAttachementCell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "Petty Cash")
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


extension PettyCashVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 3{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PettyCashAttachementCell", for: indexPath) as? PettyCashAttachementCell else {
                return UITableViewCell()
            }
            cell.configureCell(model: sections[indexPath.row])
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PettyCashCell", for: indexPath) as? PettyCashCell else {
                return UITableViewCell()
            }
            cell.configureCell(model: sections[indexPath.row])
            cell.selectionStyle = .none
            return cell

        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
