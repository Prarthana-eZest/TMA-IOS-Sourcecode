//  EnrichSalon
//
//  Created by Aman Gupta on 3/4/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//
import Foundation
import Alamofire
typealias NetworkCompletionHandlerAlamofire = (DataResponse<Data>) -> Void
public typealias ErrorHandlerAlamofire = (String) -> Void

public enum APIErrorMessage: CustomStringConvertible {
    case internetConnectionError

    public var description: String {
        switch self {
        // Use Internationalization, as appropriate.
        case .internetConnectionError:
            return "The Internet connection appears to be offline."
        }
    }
}

open class NetworkLayerAlamofire {

    //revenue API taking much time so timeout considered as 5 minutes
    static let requestTimeOut: TimeInterval = 300
    public init() {
    }

    open func delete<T: Decodable>(urlString: String,
                                   headers: [String: String] = [:],
                                   successHandler: @escaping (T) -> Void,
                                   errorHandler: @escaping ErrorHandlerAlamofire) {
        // *********** NETWORK CONNECTION
        if !NetworkRechability.isConnectedToNetwork() {
            errorHandler(APIErrorMessage.internetConnectionError.description)
            return
        }
        let completionHandler: NetworkCompletionHandlerAlamofire = { (DataResponse) in
            if let error = DataResponse.error {
                print(error.localizedDescription)
                errorHandler(error.localizedDescription)
                return
            }

            if let response = DataResponse.response {
                 if self.isServiceUnderMaintainance(DataResponse.response) {
                    ApplicationFactory.shared.moveToMaintenanceScreen(message: "")
                return
                }
            }

            //Refresh Token Code
            if self.isUserAuthorizedSuccessCode(DataResponse.response) && GenericClass.sharedInstance.isuserLoggedIn().status {
                self.refreshTokenForGet(urlString: urlString, headers: headers, successHandler: successHandler, errorHandler: errorHandler)
            }
            else {
                if self.isSuccessCode(DataResponse.response) {
                    guard let data = DataResponse.data else {
                        print("Unable to parse the response in given type \(T.self)")
                        return errorHandler(GenericError)
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(T.self, from: data)
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print(jsonString)
                        }
                        successHandler(responseObject)
                    }
                    catch {
                        print(error)
                        return errorHandler( urlString + error.localizedDescription)

                    }
                    return
                }

                if self.isSuccessWithErrorCode(DataResponse.response) {
                    guard let data = DataResponse.data else {
                        print("Unable to parse the response in given type \(T.self)")
                        return errorHandler("Unable to parse the response in given type")
                    }
                    if let responseObject = try? JSONDecoder().decode(CustomError.self, from: data) {
                        //                    if let jsonString = String(data: data, encoding: .utf8) {
                        //                        print(jsonString)
                        errorHandler((responseObject.message ?? "Server not responding.Please try after some time.") + "\n\(responseObject.parameters?.resources ?? "")")

                        //                    }

                        return
                    }
                }

                errorHandler(GenericError)
            }
        }

        var strUrlObj: String = ""
        //        if urlString.containsIgnoringCase(find: "https") {
        //            strUrlObj = urlString
        //        }else{
        strUrlObj = createBaseUrl(endPoint: urlString)
        //        }

        guard let url = URL(string: strUrlObj) else {
            return errorHandler("Unable to create URL from given string")
        }

        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = getHeaders()//headers
        request.httpMethod = "DELETE"
        request.timeoutInterval = NetworkLayerAlamofire.requestTimeOut
        if !headers.isEmpty {
            for (key, value) in headers {
                if key == "Authorization" {
                    request.allHTTPHeaderFields?[key] = "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"
                }
                else {
                    request.allHTTPHeaderFields?[key] = value
                }
            }
        }
        //  print("Headers: \(request.allHTTPHeaderFields)")
        Alamofire.request(request).responseData(completionHandler: completionHandler)
    }

    open func get<T: Decodable>(urlString: String,
                                headers: [String: String] = [:],
                                successHandler: @escaping (T) -> Void,
                                errorHandler: @escaping ErrorHandlerAlamofire) {
        // *********** NETWORK CONNECTION
        if !NetworkRechability.isConnectedToNetwork() {
            errorHandler(APIErrorMessage.internetConnectionError.description)
            return
        }
        let completionHandler: NetworkCompletionHandlerAlamofire = { (DataResponse) in
            if let error = DataResponse.error {
                print(error.localizedDescription)
                errorHandler(error.localizedDescription)
                return
            }

            if let response = DataResponse.response {
                 if self.isServiceUnderMaintainance(DataResponse.response) {
                    ApplicationFactory.shared.moveToMaintenanceScreen(message: "")
                return
                }
            }

            // Refresh Token Code
            if self.isUserAuthorizedSuccessCode(DataResponse.response) && GenericClass.sharedInstance.isuserLoggedIn().status {
                self.refreshTokenForGet(urlString: urlString, headers: headers, successHandler: successHandler, errorHandler: errorHandler)
            }
            else {

                if self.isSuccessCode(DataResponse.response) {
                    guard let data = DataResponse.data else {
                        print("Unable to parse the response in given type \(T.self)")
                        return errorHandler(GenericError)
                    }

                    //                if let responseObject = try? JSONDecoder().decode(T.self, from: data) {
                    //                    successHandler(responseObject)
                    //                    return
                    //                    }
                    do {
                        let responseObject = try JSONDecoder().decode(T.self, from: data)
                        if let jsonString = String(data: data, encoding: .utf8) {
                            //TODO: Commented printing response to resolve time consumption for Revenue Dashboard
                            //print(jsonString)
                        }
                        successHandler(responseObject)
                    }
                    catch {
                        print(error)
                        return errorHandler( urlString + error.localizedDescription)

                    }
                    return
                }

                if self.isSuccessWithErrorCode(DataResponse.response) {
                    guard let data = DataResponse.data else {
                        print("Unable to parse the response in given type \(T.self)")
                        return errorHandler("Unable to parse the response in given type")
                    }
                    if let responseObject = try? JSONDecoder().decode(CustomError.self, from: data) {
                        //                    if let jsonString = String(data: data, encoding: .utf8) {
                        //                        print(jsonString)
                        errorHandler((responseObject.message ?? "Server not responding.Please try after some time.") + "\n\(responseObject.parameters?.resources ?? "")")
                        //                    }

                        return
                    }
                }
                errorHandler(GenericError)

            }

        }

        var urlString = createBaseUrl(endPoint: urlString)
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""

        guard let url = URL(string: urlString) else {
            return errorHandler("Unable to create URL from given string")
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        request.timeoutInterval = NetworkLayerAlamofire.requestTimeOut
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"

        if !headers.isEmpty {
            for (key, value) in headers {
                if key == "Authorization" {
                    request.allHTTPHeaderFields?[key] = "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"
                }
                else {
                    request.allHTTPHeaderFields?[key] = value
                }
            }
        }
        Alamofire.request(request).responseData(completionHandler: completionHandler)

    }

    open func post<T: Encodable, F: Decodable>(urlString: String,
                                               body: T,
                                               headers: [String: String] = [:],
                                               successHandler: @escaping (F) -> Void,
                                               errorHandler: @escaping ErrorHandlerAlamofire, method: HTTPMethod) {
        // *********** NETWORK CONNECTION

        if !NetworkRechability.isConnectedToNetwork() {
            errorHandler(APIErrorMessage.internetConnectionError.description)
            return
        }

        let completionHandler: NetworkCompletionHandlerAlamofire = { (DataResponse) in
            if let error = DataResponse.error {
                print(error.localizedDescription)
                errorHandler(error.localizedDescription)
                return
            }

            if let response = DataResponse.response {
                 if self.isServiceUnderMaintainance(DataResponse.response) {
                    ApplicationFactory.shared.moveToMaintenanceScreen(message: "")
                return
                }
            }

            // Refresh Token Code
            if self.isUserAuthorizedSuccessCode(DataResponse.response) && GenericClass.sharedInstance.isuserLoggedIn().status {
                self.refreshTokenForPutDeletePost(urlString: urlString, body: body, headers: headers, successHandler: successHandler, errorHandler: errorHandler, method: method)
                return
            }
            else {

                if self.isSuccessCode(DataResponse.response) {
                    guard let data = DataResponse.data else {
                        return errorHandler("Unable to parse the response in given type")
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(F.self, from: data)
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print(jsonString)
                        }
                        successHandler(responseObject)
                    }
                    catch {
                        print(error)
                        return errorHandler( urlString + error.localizedDescription)

                    }
                    return
                }

                if self.isSuccessWithErrorCode(DataResponse.response) {
                    guard let data = DataResponse.data else {
                        return errorHandler("Unable to parse the response in given type")
                    }
                    if let responseObject = try? JSONDecoder().decode(CustomError.self, from: data) {
                        //                    if let jsonString = String(data: data, encoding: .utf8) {
                        //                        print(jsonString)
                        errorHandler((responseObject.message ?? "Server not responding.Please try after some time.") + "\n\(responseObject.parameters?.resources ?? "")")

                        //                    }

                        return
                    }
                }

                errorHandler(GenericError)

            }

        }

        guard let url = URL(string: createBaseUrl(endPoint: urlString)) else {
            return errorHandler("Unable to create URL from given string")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = NetworkLayerAlamofire.requestTimeOut
        request.httpMethod = method.rawValue
        //request.allHTTPHeaderFields = getHeaders()//headers
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        if !headers.isEmpty {
            for (key, value) in headers {
                if key == "Authorization" {
                    request.allHTTPHeaderFields?[key] = "Bearer \(GenericClass.sharedInstance.isuserLoggedIn().accessToken)"
                }
                else {
                    request.allHTTPHeaderFields?[key] = value
                }
            }
        }

        guard let data = try? JSONEncoder().encode(body) else {
            return errorHandler("Cannot encode given object into Data")
        }
        
        do {
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        }
        catch {
            print(error)
        }
        request.httpBody = data

        Alamofire.request(request).responseData(completionHandler: completionHandler)

    }

    private func isSuccessCode(_ statusCode: Int) -> Bool {
        // return statusCode >= 200 && statusCode < 300
        return statusCode == 200

    }

    private func isSuccessCode(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isSuccessCode(urlResponse.statusCode)
    }

    private func isServiceUnderMaintainance(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isServiceUnderMaintainance(urlResponse.statusCode)
    }

    private func isServiceUnderMaintainance(_ statusCode: Int) -> Bool {
        return statusCode == 502 || statusCode == 503
    }

    private func isSuccessWithErrorCode(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isSuccessWithErrorCode(urlResponse.statusCode)
    }

    private func isSuccessWithErrorCode(_ statusCode: Int) -> Bool {
           return statusCode >= 400 && statusCode < 500
       }

    private func createBaseUrl(endPoint: String) -> String {

        var  BaseUrl = ""
        var finalEndpoint = ""

        #if DEBUG
        print("DEBUG")
        //BaseUrl = "https://dev.enrichsalon.co.in/"
        BaseUrl = "https://dev.enrichbeauty.com/"

        #elseif STAGE
        print("STAGE")
        //BaseUrl = "https://stage.enrichbeauty.com/"
        BaseUrl = "https://preprod.enrichbeauty.com/"
//        BaseUrl = "https://enrichsalon.co.in/"
        
        #elseif RELEASE
        print("RELEASE")
        BaseUrl = "https://enrichsalon.co.in/"

        #endif

        finalEndpoint = String(format: "%@%@", BaseUrl, endPoint)

        print("finalEndpoint \(finalEndpoint)")
        return finalEndpoint
    }

}
// MARK: - Refresh Token Calls
extension NetworkLayerAlamofire {

    // MARK: GET : refreshTokenForGet
    func refreshTokenForGet<T: Decodable>(urlString: String,
                                          headers: [String: String] = [:],
                                          successHandler: @escaping (T) -> Void,
                                          errorHandler: @escaping ErrorHandlerAlamofire) {
        print("Refresh Token For Get request")

        // *********** NETWORK CONNECTION
        if !NetworkRechability.isConnectedToNetwork() {
            errorHandler(APIErrorMessage.internetConnectionError.description)
            return
        }

        let completionHandlerObj: NetworkCompletionHandlerAlamofire = { (DataResponse) in
            if let error = DataResponse.error {
                print(error.localizedDescription)
               // errorHandler(sessionExpire)
                self.showSessionExpiryAlert(message: sessionExpire)
                return
            }

            if self.isSuccessCode(DataResponse.response) {

                guard let data = DataResponse.data else {
                    print("Unable to parse the response in given type \(T.self)")
                    return errorHandler(GenericError)
                }
                do {
                    let objectData = try JSONDecoder().decode(RefreshResponse.self, from: data)
                    if objectData.success == false {
                        //errorHandler(sessionExpire)
                        self.showSessionExpiryAlert(message: sessionExpire)
                        return
                    }

                    self.SetAccessTokenData(objectData: objectData)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print(jsonString)
                    }
                    self.get(urlString: urlString, headers: headers, successHandler: successHandler, errorHandler: errorHandler)

                }
                catch {
                    print(error)
                    self.showSessionExpiryAlert(message: sessionExpire)
                    //errorHandler(self.errorForParsingIssue(actualError: urlString + error.localizedDescription))
                    return

                }
                return
            }
            errorHandler(GenericErrorLoginRefreshToken)
        }

        // CALL REFRESH TOKEN API

        generateRequestForRefreshToken(completionHandler: completionHandlerObj, errorHandler: errorHandler)
    }

    // MARK: POST/PUT : refreshTokenForPutDeletePost
    func refreshTokenForPutDeletePost<T: Encodable, F: Decodable>(urlString: String,
                                                                  body: T,
                                                                  headers: [String: String] = [:],
                                                                  successHandler: @escaping (F) -> Void,
                                                                  errorHandler: @escaping ErrorHandlerAlamofire, method: HTTPMethod) {

        print("Refresh Token For Post request")

        // *********** NETWORK CONNECTION
        if !NetworkRechability.isConnectedToNetwork() {
            errorHandler(APIErrorMessage.internetConnectionError.description)
            return
        }

        let completionHandlerObj: NetworkCompletionHandlerAlamofire = { (DataResponse) in
            if let error = DataResponse.error {
                print(error.localizedDescription)
               // errorHandler(sessionExpire)
                self.showSessionExpiryAlert(message: sessionExpire)
                return
            }

            if self.isSuccessCode(DataResponse.response) {
                guard let data = DataResponse.data else {
                    return errorHandler("Unable to parse the response in given type")
                }
                do {
                    let objectData = try JSONDecoder().decode(RefreshResponse.self, from: data)
                    if objectData.success == false {
                        //errorHandler(sessionExpire)
                        self.showSessionExpiryAlert(message: sessionExpire)
                        return
                    }
                    self.SetAccessTokenData(objectData: objectData)

                    if let jsonString = String(data: data, encoding: .utf8) {
                        print(jsonString)
                    }
                    self.post(urlString: urlString, body: body, headers: headers, successHandler: successHandler, errorHandler: errorHandler, method: method)
                }
                catch {
                    print(error)
                    self.showSessionExpiryAlert(message: sessionExpire)
                    return //errorHandler(self.errorForParsingIssue(actualError: urlString + error.localizedDescription))
                }
                return
            }
            errorHandler(GenericErrorLoginRefreshToken)
        }

        // CALL REFRESH TOKEN API
        generateRequestForRefreshToken(completionHandler: completionHandlerObj, errorHandler: errorHandler)
    }

    func generateRequestForRefreshToken(completionHandler: @escaping NetworkCompletionHandlerAlamofire, errorHandler :  @escaping ErrorHandlerAlamofire) {

        // Generate request
        guard let url = URL(string: createBaseUrl(endPoint: ConstantAPINames.refreshToken.rawValue)) else {
            return errorHandler("Unable to create URL from given string")
        }
        EZLoadingActivity.show("Loading...", disableUI: true)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = NetworkLayerAlamofire.requestTimeOut
        // Header
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"

        // Body
        let dataObj = GenericClass.sharedInstance.isuserLoggedIn()
        let bodyDict = RefreshRequest(access_token: dataObj.accessToken, refresh_token: dataObj.refreshToken)
        guard let data = try? JSONEncoder().encode(bodyDict) else {
            return errorHandler("Cannot encode given object into Data")
        }
        request.httpBody = data

        Alamofire.request(request).responseData(completionHandler: completionHandler)
    }

    private func isUserAuthorizedSuccessCode(_ statusCode: Int) -> Bool {
        return statusCode == 401 //|| statusCode == 403
    }

    private func isUserAuthorizedSuccessCode(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isUserAuthorizedSuccessCode(urlResponse.statusCode)
    }

    // MARK: - SET ACCESS TOKEN
    func SetAccessTokenData(objectData: RefreshResponse) {
        if  let userLoggedIn = GenericClass.sharedInstance.getUserLoggedInInfoKeyChain() {
            let model = LoginModule.UserLogin.UserData(
                access_token: objectData.data?.access_token ?? "",
                refresh_token: userLoggedIn.refresh_token ?? "",
                username: userLoggedIn.username ?? "",
                employee_id: userLoggedIn.employee_id ?? "",
                firstname: userLoggedIn.firstname ?? "",
                middlename: userLoggedIn.middlename ?? "",
                lastname: userLoggedIn.lastname ?? "",
                nickname: userLoggedIn.nickname ?? "",
                employee_code: userLoggedIn.employee_code ?? "",
                birthdate: userLoggedIn.birthdate ?? "",
                designation: userLoggedIn.designation ?? "",
                base_salon_code: userLoggedIn.base_salon_code ?? "",
                base_salon_name: userLoggedIn.base_salon_name ?? "",
                salon_id: userLoggedIn.salon_id ?? "",
                gender: userLoggedIn.gender ?? "",
                profile_image: userLoggedIn.profile_image ?? "",
                rating: userLoggedIn.rating ?? "0")

            if let data = try? JSONEncoder().encode(model) {
                GenericClass.sharedInstance.setUserLoggedInfoInKeyChain(data: data)
            }
        }
    }

    private func errorForParsingIssue(actualError: String) -> String {

        var  genericError = GenericError
        #if DEBUG
        print("DEBUG")
        genericError = actualError
        #elseif STAGE
        print("STAGE")
        genericError = actualError
        #endif

        return genericError
    }

    func showSessionExpiryAlert(message: String) {
        EZLoadingActivity.hide()
        let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: AlertButtonTitle.ok, style: UIAlertAction.Style.cancel) { _ -> Void in
            UserFactory.shared.signOutUserFromApp()
        })
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: false, completion: nil)
    }

}
