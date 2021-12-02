//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit

class ErrorCodeHandlerClass: NSObject {

    static let shared = ErrorCodeHandlerClass()

    func checkErrorCodes(error: Error?) -> String? {

        if let errorObj = error {
            return errorObj.localizedDescription
        }

        return nil
    }

}
