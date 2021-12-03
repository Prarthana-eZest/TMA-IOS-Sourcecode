//
//  ServerUnderMaintenanceModuleVC.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 24/06/20.
//  Copyright © 2020 Aman Gupta. All rights reserved.
//

import UIKit
import MessageUI

class ServerUnderMaintenanceModuleVC: UIViewController {

    @IBOutlet weak private var lblHeaderText: UILabel!
    @IBOutlet weak private var lblCallUs: LabelButton!
    @IBOutlet weak private var lblWhatsApp: LabelButton!
    @IBOutlet weak private var lblEmail: LabelButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLabelData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        EZLoadingActivity.hide()
        AppDelegate.OrientationLock.lock(to: UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isHidden = false

    }
    func setLabelData() {
        lblCallUs.onClick = {
                   // TODO
            salonDefaultNumer.makeACall()

               }
        lblWhatsApp.onClick = {
            // TODO
            self.callWhatsUp()
        }
        lblEmail.onClick = {
            // TODO
            self.sendEmail()
        }
        lblCallUs.text = salonDefaultNumer
        lblWhatsApp.text = salonDefaultWhatsAppNumber
        lblEmail.text = salonCustomerCareEmail
    }

    func callWhatsUp() {
        let urlWhats = "whatsapp://send?phone=91\(salonDefaultWhatsAppNumber)&text=Hi Enrich"

                   if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                       if let whatsappURL = NSURL(string: urlString) {
                           if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                               UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: { (_) in

                               })

                           }
                           else {
                               salonDefaultWhatsAppNumber.makeACall()
                           }
                       }
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
extension ServerUnderMaintenanceModuleVC: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([salonCustomerCareEmail])
            mail.setMessageBody("<p>Hi Enrich,</p>", isHTML: true)

            present(mail, animated: true)
        }
        else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
