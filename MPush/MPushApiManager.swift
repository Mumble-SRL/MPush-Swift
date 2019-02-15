//
//  MPushApiManager.swift
//  MPush
//
//  Copyright © 2018 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation
import UIKit
import Alamofire

/// An error of the MPush apis
public struct MPushError: Error, LocalizedError, CustomStringConvertible {
    
    /// Domain of the error
    let domain: String
    
    /// Code of the error
    let code: Int
    
    /// Message of the error
    let message: String
    
    /// The complete description of the error
    public var description: String {
        return "Error domain: \(domain) (\(code))\n\(message)"
    }
    
    /// The error description
    public var errorDescription: String? {
        return self.message
    }
}

/// General class that calls the apis using Alamofire
internal class MPushApiManager: NSObject {
    static let baseUrl = "https://push.mumbleserver.it/api"

    /// Calls a MPush api using Alamofire
    ///
    /// - Parameters:
    ///   - name: the name of the api
    ///   - method: the HTTP method
    ///   - parameters: the parameters passed to the api
    ///   - headers: the headers passed to the api
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and one argument: the response of the api.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    internal static func callApi(withName name: String,
                                 method: HTTPMethod,
                                 parameters: [String: Any]?,
                                 headers: [String: String]?,
                                 success: ((_ response: [String: Any]) -> Void)? = nil,
                                 failure: ((_ error: Error?) -> Void)? = nil) {
        let completeUrlString = baseUrl + "/" + name
        if let url = URL(string: completeUrlString) {
            Alamofire.request(url, method: method, parameters: parameters, headers: headers).responseJSON { (response) in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [String: Any] {
                        self.parseJsonResponse(response: response, json: json, success: success, failure: failure)
                    } else {
                        if let failure = failure {
                            failure(response.error)
                        }
                    }
                case .failure(let error):
                    if let failure = failure {
                        failure(error)
                    }
                }
            }
        } else {
            if let failure = failure {
                failure(MPushError(domain: "com.mumble.push",
                                   code: 101,
                                   message: "URL(\(completeUrlString) is in the wrong format"))
            }
        }
    }
    
    /// Parses the response of the api and returns a dictionary or an error
    ///
    /// - Parameters:
    ///   - response: the response from Alamofire
    ///   - json: the json returned from Alamofire
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and one argument: the response of the api as a dictionary.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    private static func parseJsonResponse(response: DataResponse<Any>,
                                          json: [String: Any],
                                          success: ((_ response: [String: Any]) -> Void)?,
                                          failure: ((_ error: Error?) -> Void)?) {
        var message = ""
        if let errors = json["errors"] as? [String: Any] {
            for key in errors.keys {
                if let errorsArray = errors[key] as? [String] {
                    if message == "" {
                        message += "\(errorsArray.joined(separator: "\n"))"
                    } else {
                        message += "\n\(errorsArray.joined(separator: "\n"))"
                    }
                }
            }
            if let failure = failure {
                let error = MPushError(domain: "com.mumble.push",
                                       code: response.response?.statusCode ?? 0,
                                       message: message)
                failure(error)
            }
        } else {
            let responseDict = json
            let statusCode = responseDict["status_code"] as? Int ?? -1
            if statusCode == 0 {
                if let success = success {
                    success(responseDict)
                }
            } else {
                let message = responseDict["message"] as? String ?? ""
                let error = MPushError(domain: "com.mumble.push",
                                       code: response.response?.statusCode ?? 0,
                                       message: message)
                if let failure = failure {
                    failure(error)
                }
            }
        }
    }
}
