//
//  ContactsHelper.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/13/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

protocol ContactsHelperDelegate: class {
    func contactListSuccess(_ qrImage: [CNContact])
    func contactListError(error: String?)
}

class ContactsHelper: NSObject {
    static var sharedInstance = ContactsHelper()
    weak var viewController: UIViewController?
    weak var delegate: ContactsHelperDelegate?

    func getContactList() {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        viewController?.present(cnPicker, animated: true, completion: nil)
    }

}
extension ContactsHelper: CNContactPickerDelegate {
    // MARK: - CNContactPickerDelegate Method

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {

        self.delegate?.contactListSuccess(contacts)
//        contacts.forEach { contact in
//            print("number is = \(contact.phoneNumbers.first) \n name \(contact.givenName) \(contact.middleName)")
//
//
//            for number in contact.phoneNumbers {
//                let phoneNumber = number.value
//                print("number is = \(phoneNumber)")
//            }
//        }
    }
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
       self.delegate?.contactListError(error: ContactsErrors.UserCancelledContacts.description)
    }

}
