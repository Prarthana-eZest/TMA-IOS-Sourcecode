//
//  AppointmentFilterViewController.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 09/10/19.
//  Copyright (c) 2019 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol AppointmentFilterDisplayLogic: class
{
    func displaySomething(viewModel: AppointmentFilter.Something.ViewModel)
}

class AppointmentFilterVC: UIViewController, AppointmentFilterDisplayLogic
{
    var interactor: AppointmentFilterBusinessLogic?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnUpcoming: UIButton!
    @IBOutlet weak var btnPast: UIButton!
    
    var servicesOptions:[CheckBoxCellModel] = [CheckBoxCellModel(title: "All service", isSelected: false),
                                               CheckBoxCellModel(title: "Beard Trimming", isSelected: false),
                                               CheckBoxCellModel(title: "Haircut", isSelected: false),
                                               CheckBoxCellModel(title: "Shaving", isSelected: false),
                                               CheckBoxCellModel(title: "Head Massage", isSelected: false)]
    
    var viewDismissBlock: ((Bool) -> Void)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = AppointmentFilterInteractor()
        let presenter = AppointmentFilterPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    // MARK: Routingå
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
//            if let router = router, router.responds(to: selector) {
//                router.perform(selector, with: segue)
//            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doSomething()
        
        tableView.register(UINib(nibName: "CheckBoxCell", bundle: nil), forCellReuseIdentifier: "CheckBoxCell")
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSomething()
    {
        let request = AppointmentFilter.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: AppointmentFilter.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
    
    @IBAction func actionClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        viewDismissBlock?(true)
    }
    
    
    @IBAction func actionUpcoming(_ sender: UIButton) {
        btnPast.isSelected = false
        btnUpcoming.titleLabel?.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 14)
        sender.isSelected = true
        sender.titleLabel?.font = UIFont(name: FontName.FuturaPTDemi.rawValue, size: 14)
    }
    
    @IBAction func actionPast(_ sender: UIButton) {
        btnUpcoming.isSelected = false
        btnUpcoming.titleLabel?.font = UIFont(name: FontName.FuturaPTBook.rawValue, size: 14)
        sender.isSelected = true
        sender.titleLabel?.font = UIFont(name: FontName.FuturaPTMedium.rawValue, size: 14)
    }
    
    @IBAction func actionClearAll(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        viewDismissBlock?(true)
    }
    
    @IBAction func actionApply(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        viewDismissBlock?(true)
    }
    
    
}

extension AppointmentFilterVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servicesOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CheckBoxCell", for: indexPath) as? CheckBoxCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(model: servicesOptions[indexPath.row])
        
        if indexPath.row == 0{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.size.width)
        }else{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 50 : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
        if indexPath.row == 0{
            let status = !servicesOptions[indexPath.row].isSelected
            for i in 0..<(servicesOptions.count){
                servicesOptions[i].isSelected = status
            }
        }else{
            servicesOptions[indexPath.row].isSelected = !servicesOptions[indexPath.row].isSelected
            if !servicesOptions[indexPath.row].isSelected && servicesOptions[0].isSelected{
                servicesOptions[0].isSelected = false
            }
        }
        tableView.reloadData()
    }
}

