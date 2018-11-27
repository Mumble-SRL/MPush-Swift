//
//  MumblePushApiManager.swift
//  MumblePush
//
//  Created by Lorenzo Oliveto on 11/06/18.
//  Copyright © 2018 Mumble. All rights reserved.
//

import UIKit
import Alamofire

public struct MumblePushError: Error, LocalizedError, CustomStringConvertible {
    let domain: String
    let code: Int
    let message: String
    
    public var description: String {
        return "Error domain: \(domain) (\(code))\n\(message)"
    }
    
    public var errorDescription: String? {
        return self.message
    }
}

internal class MumblePushApiManager: NSObject {
    static let baseUrl = "https://push.mumbleserver.it/api"

    internal static func callApi(withName name: String,
                                 method: HTTPMethod,
                                 parameters: [String: Any]?,
                                 headers: [String: String]?,
                                 success: ((_ response: [String: Any]) -> Void)? = nil,
                                 failure: ((_ error: Error?) -> Void)? = nil) {
        let completeUrlString = baseUrl + "/" + name
        if let url = URL(string: completeUrlString){
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
        }
        else {
            if let failure = failure {
                failure(MumblePushError(domain: "com.mumble.push",
                                        code: 101,
                                        message: "URL(\(completeUrlString) is in the wrong format"))
            }
        }
    }
    
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
                let error = MumblePushError(domain: "com.mumble.push",
                                            code: response.response?.statusCode ?? 0,
                                            message: message)
                failure(error)
            }
        } else {
            if let responseDict = json["response"] as? [String: Any] {
                let statusCode = responseDict["status_code"] as? Int ?? -1
                if statusCode == 0 {
                    if let success = success {
                        success(responseDict)
                    }
                } else {
                    let message = responseDict["message_localized"] as? String ?? ""
                    let error = MumblePushError(domain: "com.mumble.push",
                                                code: response.response?.statusCode ?? 0,
                                                message: message)
                    if let failure = failure {
                        failure(error)
                    }
                }
            } else {
                let error = MumblePushError(domain: "com.mumble.push",
                                            code: response.response?.statusCode ?? 0,
                                            message: "Can't find response")
                if let failure = failure {
                    failure(error)
                }
            }
        }
    }
}
