//
//  ContactsError.swift
//  EnrichSalon
//
//  Created by Aman Gupta on 3/13/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

public enum ContactsErrors: CustomStringConvertible {
    case UserCancelledContacts

    public var description: String {
        switch self {
        // Use Internationalization, as appropriate.
        case .UserCancelledContacts:
            return "Cancel Contact Picker"
        }
    }
}
