//
//  MPushApiManager.swift
//  MPush
//
//  Copyright © 2018 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation
import UIKit
import MBNetworkingSwift

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

/// General class that calls the apis using MBNetworking
internal class MPushApiManager {
    /// The URL used to do the api calls.
    static private let baseUrl = "https://app.mpush.cloud/api"

    /// Calls a MPush api using MBNetworking
    /// - Parameters:
    ///   - name: the name of the api
    ///   - method: the HTTP method
    ///   - parameters: the parameters passed to the api
    ///   - headers: the headers passed to the api
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and one argument: the response of the api.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    
    internal static func callApi(withName name: String,
                                 method: HTTPMethod,
                                 parameters: Parameters?,
                                 headers: [HTTPHeader]?,
                                 success: ((_ response: [String: Any]) -> Void)? = nil,
                                 failure: ((_ error: Error?) -> Void)? = nil) {
        let completeUrlString = baseUrl + "/" + name
        var compelteHeaders = headers ?? []
        compelteHeaders.append(HTTPHeader(field: "Accept", value: "application/json"))
        compelteHeaders.append(HTTPHeader(field: "Content-Type", value: "application/json"))
        MBNetworking.request(withUrl: completeUrlString,
                             method: method,
                             headers: compelteHeaders,
                             parameters: parameters,
                             encoding: JSONParameterEncoder.default) { response in
                                parseJsonResponse(response: response, success: success, failure: failure)
        }
    }
    
    /// Parses the response of the api and returns a dictionary or an error
    /// - Parameters:
    ///   - response: the response from MBNetworking
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and one argument: the response of the api as a dictionary.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    private static func parseJsonResponse(response: MBResponse<Any>,
                                          success: ((_ response: [String: Any]) -> Void)?,
                                          failure: ((_ error: Error) -> Void)?) {
        switch response.result {
        case .success(let responseDictionary):
            guard let json = responseDictionary as? [String: Any] else {
                if let failure = failure {
                    failure(MPushError(domain: "com.mumble.push",
                                       code: 9000,
                                       message: "could't cast response to Dictionary")
                    )
                }
                return
            }
            
            if let error = checkForErrors(in: json, with: response.response) {
                if let failure = failure {
                    failure(error)
                }
            } else {
                if let success = success {
                    success(json)
                }
            }
        case .error(let error):
            if let failure = failure {
                failure(error)
            }
        }
    }
    
    /// Parses the response in search of an error.
    /// - Parameters:
    ///   - json: A dictionary that contains the api response.
    ///   - response: The HTTPURLResponse of the call, if present. Needed to create the status code of the error.
    /// - Returns: If an error is found in the response, it returns the reason why the call is failed.
    private static func checkForErrors(in json: [String: Any], with response: HTTPURLResponse?) -> Error? {
        var message = ""
        guard let errors = json["errors"] as? [String: Any] else {
            return nil }
        
        for key in errors.keys {
            if let errorsArray = errors[key] as? [String] {
                if message == "" {
                    message += "\(errorsArray.joined(separator: "\n"))"
                } else {
                    message += "\n\(errorsArray.joined(separator: "\n"))"
                }
            }
        }
        
        return MPushError(domain: "com.mumble.push",
                          code: response?.statusCode ?? 0,
                          message: message)
    }
}
