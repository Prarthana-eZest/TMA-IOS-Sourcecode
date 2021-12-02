//
//  MyCustomersViewController.swift
//  Enrich_TMA
//
//  Created by Harshal Patil on 16/10/19.
//  Copyright (c) 2019 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MyCustomersDisplayLogic: class
{
    func displaySomething(viewModel: MyCustomers.Something.ViewModel)
}

class MyCustomersVC: UIViewController, MyCustomersDisplayLogic
{
    var interactor: MyCustomersBusinessLogic?
    
    @IBOutlet weak var tableView: UITableView!
    
    
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
        let interactor = MyCustomersInteractor()
        let presenter = MyCustomersPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //    if let scene = segue.identifier {
        //      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
        //      if let router = router, router.responds(to: selector) {
        //        router.perform(selector, with: segue)
        //      }
        //    }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doSomething()
        
        tableView.register(UINib(nibName: "MyCustomersHeaderCell", bundle: nil), forCellReuseIdentifier: "MyCustomersHeaderCell")
        tableView.register(UINib(nibName: "MyCustomerCell", bundle: nil), forCellReuseIdentifier: "MyCustomerCell")
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.size.width)
        
        showNavigationBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.addCustomBackButton(title: "My Customers")
    }
    
    // MARK: - Top Navigation Bar And  Actions
    func showNavigationBarButtons() {
        
        guard let searchImg = UIImage(named: "searchImg") else{
                return
        }
        
        let searchButton = UIBarButtonItem(image: searchImg, style: .plain, target: self, action: #selector(didTapSearchButton))
        searchButton.tintColor = UIColor.black
        
        navigationItem.title = ""
        navigationItem.rightBarButtonItems = [searchButton]
    }
    
    @objc func didTapSearchButton() {
        let vc = SearchByVC.instantiate(fromAppStoryboard: .More)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSomething()
    {
        let request = MyCustomers.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: MyCustomers.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }
}

extension MyCustomersVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomersHeaderCell", for: indexPath) as? MyCustomersHeaderCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomerCell", for: indexPath) as? MyCustomerCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection")
    }
}
