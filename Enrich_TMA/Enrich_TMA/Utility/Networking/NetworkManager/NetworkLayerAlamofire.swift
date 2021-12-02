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
        case .internetConnectionError: return "The Internet connection appears to be offline."
            
        }
    }
}

open class NetworkLayerAlamofire {
    
    static let requestTimeOut: TimeInterval = 60
    public init() {
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
            
            /* Refresh Token Code
             if self.isUserAuthorizedSuccessCode(DataResponse.response)
             {
             self.getRequestRefreshToken(urlString: urlString, headers: headers, successHandler: successHandler, errorHandler: errorHandler)
             return
             }*/
            
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
                        print(jsonString)
                    }
                    successHandler(responseObject)
                } catch {
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
                    errorHandler(responseObject.message ?? "Server not responding.Please try after some time.")
                    
                    //                    }
                    
                    return
                }
            }
            
            errorHandler(GenericError)
        }
        
        guard let url = URL(string: createBaseUrl(endPoint: urlString)) else {
            return errorHandler("Unable to create URL from given string")
        }
        
        var request = URLRequest(url: url)
        //request.allHTTPHeaderFields = getHeaders()//headers
        request.httpMethod = "GET"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        
        if(!headers.isEmpty) {
            for (key, value) in headers {
                request.allHTTPHeaderFields?[key] = value
            }
        }
        Alamofire.request(request).responseData(completionHandler: completionHandler)
        
    }
    
    open func post<T: Encodable, F: Decodable>(urlString: String,
                                               body: T,
                                               headers: [String: String] = [:],
                                               successHandler: @escaping (F) -> Void,
                                               errorHandler: @escaping ErrorHandlerAlamofire,method: HTTPMethod) {
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
            /* Refresh Token Code
             if self.isUserAuthorizedSuccessCode(DataResponse.response)
             {
             self.putDeletePostRequestRefreshToken(urlString: urlString, body: body, successHandler: successHandler, errorHandler: errorHandler, method: method)
             return
             }*/
            
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
                } catch {
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
                    errorHandler(responseObject.message ?? "Server not responding.Please try after some time.")
                    
                    //                    }
                    
                    return
                }
            }
            
            errorHandler(GenericError)
        }
        
        guard let url = URL(string: createBaseUrl(endPoint: urlString)) else {
            return errorHandler("Unable to create URL from given string")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = NetworkLayerAlamofire.requestTimeOut
        request.httpMethod = method.rawValue
        //request.allHTTPHeaderFields = getHeaders()//headers
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        if(!headers.isEmpty) {
            for (key, value) in headers {
                request.allHTTPHeaderFields?[key] = value
            }
        }
        
        guard let data = try? JSONEncoder().encode(body) else {
            return errorHandler("Cannot encode given object into Data")
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
    
    private func isSuccessWithErrorCode(_ statusCode: Int) -> Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    private func isSuccessWithErrorCode(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isSuccessWithErrorCode(urlResponse.statusCode)
    }
    
    private func createBaseUrl(endPoint: String) -> String {
        
        // "http://dummy.restapiexample.com/api/v1/" dummy data
        var  BaseUrl = "https://enrich-magento.e-zest.net/rest/V1/"
        #if DEBUG
        print("DEBUG")
        BaseUrl = "https://enrich-magento.e-zest.net/rest/V1/"
        #elseif RELEASE
        print("RELEASE")
        BaseUrl = "https://enrich-magento.e-zest.net/rest/V1/"
        #endif
        
        var finalEndpoint = ""
        finalEndpoint = String(format: "%@%@", BaseUrl, endPoint)
        print("finalEndpoint \(finalEndpoint)")
        return finalEndpoint
    }
    
}
//MARK: Refresh Token Code Added
extension NetworkLayerAlamofire {
    
    
    func getRequestRefreshToken<T: Decodable>(urlString: String,
                                              headers: [String: String] = [:],
                                              successHandler: @escaping (T) -> Void,
                                              errorHandler: @escaping ErrorHandlerAlamofire) {
        // *********** NETWORK CONNECTION
        if !NetworkRechability.isConnectedToNetwork() {
            errorHandler(APIErrorMessage.internetConnectionError.description)
            return
        }
        
        
        let completionHandler: NetworkCompletionHandlerAlamofire = { (DataResponse) in
            //            if let error = DataResponse.error {
            //                print(error.localizedDescription)
            //                errorHandler(error.localizedDescription)
            //                return
            //            }
            
            if self.isSuccessCode(DataResponse.response) {
                guard let data = DataResponse.data else {
                    print("Unable to parse the response in given type \(T.self)")
                    return errorHandler(GenericError)
                }
                do {
                    _ = try JSONDecoder().decode(T.self, from: data)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print(jsonString)
                    }
                    self.get(urlString: urlString, headers: headers, successHandler: successHandler, errorHandler: errorHandler)
                    
                } catch {
                    print(error)
                    return errorHandler( urlString + error.localizedDescription)
                    
                }
                return
            }
            else {
                self.getRequestRefreshToken(urlString: urlString, headers: headers, successHandler: successHandler, errorHandler: errorHandler)
            }
            
            
            
            errorHandler(GenericError)
        }
        
        #warning("TODO: URL needs to be change")
        guard let url = URL(string: createBaseUrl(endPoint: ConstantAPINames.validateOTPOnLogin.rawValue)) else {
            return errorHandler("Unable to create URL from given string")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        
        if(!headers.isEmpty) {
            for (key, value) in headers {
                request.allHTTPHeaderFields?[key] = value
            }
        }
        Alamofire.request(request).responseData(completionHandler: completionHandler)
        
    }
    
    func putDeletePostRequestRefreshToken<T: Encodable, F: Decodable>(urlString: String,
                                                                      body: T,
                                                                      headers: [String: String] = [:],
                                                                      successHandler: @escaping (F) -> Void,
                                                                      errorHandler: @escaping ErrorHandlerAlamofire,method: HTTPMethod) {
        // *********** NETWORK CONNECTION
        if !NetworkRechability.isConnectedToNetwork() {
            errorHandler(APIErrorMessage.internetConnectionError.description)
            return
        }
        
        let completionHandler: NetworkCompletionHandlerAlamofire = { (DataResponse) in
            //            if let error = DataResponse.error {
            //                print(error.localizedDescription)
            //                errorHandler(error.localizedDescription)
            //                return
            //            }
            
            if self.isSuccessCode(DataResponse.response) {
                guard let data = DataResponse.data else {
                    return errorHandler("Unable to parse the response in given type")
                }
                do {
                    _ = try JSONDecoder().decode(F.self, from: data)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print(jsonString)
                    }
                    self.post(urlString: urlString, body: body, successHandler: successHandler, errorHandler: errorHandler, method: method)
                } catch {
                    print(error)
                    return errorHandler( urlString + error.localizedDescription)
                    
                }
                return
            }
                
            else {
                self.putDeletePostRequestRefreshToken(urlString: urlString, body: body, headers: headers, successHandler: successHandler, errorHandler: errorHandler, method: method)
            }
            
            
            errorHandler(GenericError)
        }
        
        #warning("TODO: URL needs to be change")
        guard let url = URL(string: createBaseUrl(endPoint: ConstantAPINames.validateOTPOnLogin.rawValue)) else {
            return errorHandler("Unable to create URL from given string")
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = NetworkLayerAlamofire.requestTimeOut
        request.httpMethod = "POST"
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        if(!headers.isEmpty) {
            for (key, value) in headers {
                request.allHTTPHeaderFields?[key] = value
            }
        }
        guard let data = try? JSONEncoder().encode(body) else {
            return errorHandler("Cannot encode given object into Data")
        }
        request.httpBody = data
        Alamofire.request(request).responseData(completionHandler: completionHandler)
        
    }
    
    private func isUserAuthorizedSuccessCode(_ statusCode: Int) -> Bool {
        return statusCode == 401 || statusCode == 403
        
    }
    
    private func isUserAuthorizedSuccessCode(_ response: URLResponse?) -> Bool {
        guard let urlResponse = response as? HTTPURLResponse else {
            return false
        }
        return isUserAuthorizedSuccessCode(urlResponse.statusCode)
    }
    
}

