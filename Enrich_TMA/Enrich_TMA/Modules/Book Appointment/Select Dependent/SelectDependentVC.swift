//
//  SelectDependentViewController.swift
//  Enrich_TMA
//
//  Created by Harshal on 23/11/20.
//  Copyright (c) 2020 e-zest. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SelectDependentDisplayLogic: class
{
    func displaySomething(viewModel: SelectDependent.Something.ViewModel)
}

class SelectDependentVC: UIViewController, SelectDependentDisplayLogic
{
    var interactor: SelectDependentBusinessLogic?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var lblCartViewHours: UILabel!
    @IBOutlet weak var lblCardViewServices: UILabel!
    
    var onDoneBlock: ((Bool) -> Void)?
    var pickerType: PickerType!
    
    // Add New Appointment
    var selectedCustomer: MyCustomers.GetCustomers.Customer?
    var selectedCustomerAddress: ManageAddressModule.CustomerAddress.Addresses?
    var appointment_id: Int64?
    var selectedServices = [AuthrosedServicesModel]()
    var selectedIndexDependent = 0

    // Change Service Timeslot
    var selectedService: ModifyServiceCellModel?
    var backView = UIView()
    
    // Add Single Service
    var appointmentDetails: Schedule.GetAppointnents.Data?
    
    var operationType: OperationType = .addSingleService
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = SelectDependentInteractor()
        let presenter = SelectDependentPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        doSomething()
        
        tableView.separatorInset = UIEdgeInsets(
            top: 0, left: tableView.frame.size.width, bottom: 0, right: 0)
        tableView.register(UINib(
            nibName: CellIdentifier.selectServiceDependentCell, bundle: nil),
            forCellReuseIdentifier: CellIdentifier.selectServiceDependentCell)
        
        backView.frame = self.view.frame
        backView.backgroundColor = .black
        self.view.addSubview(backView)
        self.view.bringSubviewToFront(backView)
        backView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var finalObject : [AuthrosedServicesModel] = selectedServices
        for (index,_) in selectedServices.enumerated() {
            let model = AuthrosedServicesModel(isSelected: selectedServices[index].isSelected, serviceDetails: selectedServices[index].serviceDetails, allowedForDependent: selectedServices[index].allowedForDependent)
            model.serviceDetails.dependant_name = nil
            model.serviceDetails.dependant_id = nil
            model.serviceDetails.dependant_note = ""
            model.serviceDetails.dependant_age = nil
            model.serviceDetails.dependant_gender = nil
            finalObject[index] = model
        }
        selectedServices = finalObject
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTimeAndData()
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    func doSomething() {
        let request = SelectDependent.Something.Request()
        interactor?.doSomething(request: request)
    }
    
    func displaySomething(viewModel: SelectDependent.Something.ViewModel) {
        //nameTextField.text = viewModel.name
    }
    
    
    @IBAction func actionBack(_ sender: UIButton) {
        onDoneBlock?(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionContinue(_ sender: UIButton) {
        if validationCheckforDependents() {
            showDateTimePicker()
        }
    }
    
    func showTimeAndData() {
        var finalAmount = 0.0
        var timeForServices = 0
        for model in selectedServices {
            finalAmount = finalAmount + (model.serviceDetails.taxable_price ?? 0.0)
            timeForServices = timeForServices + (Int(model.serviceDetails.service_time ?? "0") ?? 0)
        }
        self.lblCardViewServices.text = "\(selectedServices.count) Services \n\(finalAmount)"
        self.lblCartViewHours.text = GenericClass().getDurationTextFromSeconds(minuts: timeForServices)
    }
    
    func showDateTimePicker() {
        let vc = ChangeTimeSlotVC.instantiate(fromAppStoryboard: .Schedule)
        backView.isHidden = false
        backView.alpha = screenPopUpAlpha
        self.view.alpha = 1.0
        vc.pickerType = pickerType
        vc.serviceType = SalonServiceAt.Salon
        vc.selectedCustomer = selectedCustomer
        vc.selectedCustomerAddress = selectedCustomerAddress
        vc.appointmentDetails = appointmentDetails
        vc.operationType = operationType
        vc.selectedServices = selectedServices.compactMap{$0.serviceDetails}
        self.present(vc, animated: true, completion: nil)
        vc.onDoneBlock = { [unowned self] (result, dateTime) in
            if result {
                self.onDoneBlock?(true)
                self.dismiss(animated: true, completion: nil)
            }
            self.backView.alpha = 1.0
            self.backView.isHidden = true
        }
    }
}
extension SelectDependentVC: DepedentDelegate {
    func actionSwitchDependent(indexPath: IndexPath, onOROff: Bool) {
        selectedIndexDependent = indexPath.row
        
        if onOROff == false {
            let model = AuthrosedServicesModel(isSelected: selectedServices[selectedIndexDependent].isSelected, serviceDetails: selectedServices[selectedIndexDependent].serviceDetails, allowedForDependent: selectedServices[selectedIndexDependent].allowedForDependent)
            model.serviceDetails.dependant_name = nil
            model.serviceDetails.dependant_id = nil
            model.serviceDetails.dependant_note = ""
            model.serviceDetails.dependant_age = nil
            model.serviceDetails.dependant_gender = nil
            model.serviceDetails.is_dependant_service = 0
            selectedServices[selectedIndexDependent] = model
        }
        
        self.tableView.reloadData()
    }
    
    func actionSelectDependent(indexPath: IndexPath) {
        
        let model = selectedServices[indexPath.row].serviceDetails
        let vc = DependentListVC.instantiate(fromAppStoryboard: .BookAppointment)
        vc.parent_view = self
        vc.selectedServiceModel = model
        vc.selectedServiceIndex = indexPath.row
        vc.service_Gender = model.gender ?? ""
        backView.isHidden = false
        backView.alpha = screenPopUpAlpha
        if operationType == .addMultipleServices {
            vc.customer_id = selectedCustomer?.id
        }else if let details = appointmentDetails {
            vc.customer_id = "\(details.booked_for_id ?? 0)"
        }
        self.view.alpha = 1.0
        self.present(vc, animated: true, completion: nil)
        vc.onDoneBlockObj = { [unowned self] (result, index, replaceModel, dependent) in
                self.backView.alpha = 1.0
                self.backView.isHidden = true
            
            if result {
                let modelFinal = AuthrosedServicesModel(isSelected: self.selectedServices[index].isSelected, serviceDetails: replaceModel, allowedForDependent: self.selectedServices[index].allowedForDependent)
                modelFinal.dependentDetails = dependent
                modelFinal.serviceDetails.dependant_gender = "\(dependent?.dependant_gender ?? 0)"
                modelFinal.serviceDetails.dependant_age = dependent?.dependant_age
                modelFinal.serviceDetails.dependant_note = dependent?.dependant_note
                modelFinal.serviceDetails.dependant_id = dependent?.dependant_id
                modelFinal.serviceDetails.dependant_name = dependent?.dependant_name
                modelFinal.serviceDetails.is_dependant_service = 1
                self.selectedServices[index] = modelFinal
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func validationCheckforDependents() -> Bool {
        // Check for Dependent repeate for same service
        let serviceDetails = selectedServices.compactMap{$0.serviceDetails}
        for (index,model) in serviceDetails.enumerated() {
            for (indexSec,modelSec) in serviceDetails.enumerated() {
                if (index != indexSec && model.dependant_name == modelSec.dependant_name && model.service_id == modelSec.service_id && model.dependant_id == modelSec.dependant_id && modelSec.dependant_id != nil && model.dependant_id != nil) {
                    
                    self.showAlert(alertTitle: "", alertMessage: "You can't add same dependent for same services")
                    return false
                }
            }
        }
        
        // Check for Customer repeate for same services
        let allNonDependentServices = serviceDetails.filter { (model) -> Bool in
            if (model.dependant_id == nil && model.dependant_name == nil) {
                return true
            }
            return false
        }
        
        let serviceIds = allNonDependentServices.compactMap({$0.service_id})
        let uniqueServiceIds = Set(serviceIds)
        
        if serviceIds.count > uniqueServiceIds.count {
            self.showAlert(alertTitle: "", alertMessage: "You can't add same customer for same services")
            return false
        }
        
        // Check for gender
        var crossGenderServices = [String]()
        serviceDetails.forEach {
            if ($0.dependant_id == nil && $0.dependant_name == nil) {
                
                if operationType == .addMultipleServices {
                    let customerGender = GenderForDependent(rawValue: Int(selectedCustomer?.gender ?? "1") ?? 1)
                    let strGender = ($0.gender ?? "")
                    if !(strGender.containsIgnoringCase(find: customerGender?.stringValue() ?? "")) {
                        self.showAlert(alertTitle: "", alertMessage: "\($0.name ?? "") is not allowed for \(customerGender?.stringType() ?? "") customer")
                        crossGenderServices.append($0.service_id ?? "")
                        return
                    }
                }
                else if operationType == .addSingleService {
                   let customerGender = GenderForDependent(rawValue: appointmentDetails?.gender ?? 1)
                   let strGender = ($0.gender ?? "")
                   if !(strGender.containsIgnoringCase(find: customerGender?.stringValue() ?? "")) {
                       self.showAlert(alertTitle: "", alertMessage: "\($0.name ?? "") is not allowed for \(customerGender?.stringType() ?? "") customer")
                       crossGenderServices.append($0.service_id ?? "")
                       return
                   }
                }
            }
        }

        if !crossGenderServices.isEmpty {
            return false
        }
        return true
    }
}



extension SelectDependentVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.selectServiceDependentCell, for: indexPath) as? SelectServiceDependentCell else {
            return UITableViewCell()
        }
        let service = selectedServices[indexPath.row].serviceDetails
        
        if operationType == .addMultipleServices {
            cell.configureCell(
            serviceName: service.name ?? "",
            price: service.price ?? 0,
            allowedForDependent: selectedServices[indexPath.row].allowedForDependent,
            depenedentName: service.dependant_name ?? "",
            customerName: ((self.selectedCustomer?.firstname ?? "") + " " + (self.selectedCustomer?.lastname ?? "")),
            serviceDuration: service.service_time ?? "0")
        }else {
            cell.configureCell(
            serviceName: service.name ?? "",
            price: service.price ?? 0,
            allowedForDependent: selectedServices[indexPath.row].allowedForDependent,
            depenedentName: service.dependant_name ?? "",
            customerName: ((self.appointmentDetails?.customer_firstname ?? "") + " " + (self.appointmentDetails?.customer_lastname ?? "")),
            serviceDuration: service.service_time ?? "0")
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        cell.selectionStyle = .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}