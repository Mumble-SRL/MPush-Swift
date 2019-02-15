//
//  MPush.swift
//  MPush
//
//  Copyright © 2018 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation
import UIKit

/// The MPush class used to do all the interactions with the service
public class MPush: NSObject {
    
    /// The token of MPush
    @objc public static var token: String?
    
    /// Register a device token
    ///
    /// - Parameters:
    ///   - deviceToken: The device token data returned in didRegisterForRemoteNotificationsWithDeviceToken
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    @objc public static func registerDevice(deviceToken: Data,
                                            success: (() -> Void)? = nil,
                                            failure: ((_ error: Error?) -> Void)? = nil) {
        if token == nil {
            if let failure = failure {
                failure(tokenError())
            }
            return
        }
        
        let deviceTokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let deviceToken = deviceTokenParts.joined()
        var parameters = self.defaultParameters()
        parameters["platform"] = "ios"
        parameters["token"] = deviceToken
        
        MPushApiManager.callApi(withName: "tokens",
                                method: .post,
                                parameters: parameters,
                                headers: self.defaultHeaders(),
                                success: { _ in
                                    if let success = success {
                                        success()
                                    }
        },
                                failure: failure)
    }
    
    /// Register the current device to a topic
    ///
    /// - Parameters:
    ///   - topic: The topic you will register to
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    @objc public static func register(toTopic topic: String,
                                      success: (() -> Void)? = nil,
                                      failure: ((_ error: Error?) -> Void)? = nil) {
        self.register(toTopics: [topic], success: success, failure: failure)
    }
    
    /// Register the current device to an array of topics
    ///
    /// - Parameters:
    ///   - topics: The topics you will register to
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    @objc public static func register(toTopics topics: [String],
                                      success: (() -> Void)? = nil,
                                      failure: ((_ error: Error?) -> Void)? = nil) {
        if token == nil {
            if let failure = failure {
                failure(tokenError())
            }
            return
        }
        
        var parameters = self.defaultParameters()
        do {
            let encodedTopics = try JSONEncoder().encode(topics)
            parameters["topics"] = String(data: encodedTopics, encoding: .utf8)
        } catch { }
        
        MPushApiManager.callApi(withName: "register",
                                method: .post,
                                parameters: parameters,
                                headers: self.defaultHeaders(),
                                success: { _ in
                                    if let success = success {
                                        success()
                                    }
        },
                                failure: failure)
    }
    
    /// Unregister the current device from a topic
    ///
    /// - Parameters:
    ///   - topic: The topic you will unregister from
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    @objc public static func unregister(fromTopic topic: String,
                                        success: (() -> Void)? = nil,
                                        failure: ((_ error: Error?) -> Void)? = nil) {
        self.unregister(fromTopics: [topic], success: success, failure: failure)
        
    }
    
    /// Unregister the current device from an array of topics
    ///
    /// - Parameters:
    ///   - topics: The topics you will unregister from
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    @objc public static func unregister(fromTopics topics: [String],
                                        success: (() -> Void)? = nil,
                                        failure: ((_ error: Error?) -> Void)? = nil) {
        if token == nil {
            if let failure = failure {
                failure(tokenError())
            }
            return
        }
        
        var parameters = self.defaultParameters()
        do {
            let encodedTopics = try JSONEncoder().encode(topics)
            parameters["topics"] = String(data: encodedTopics, encoding: .utf8)
        } catch { }
        
        MPushApiManager.callApi(withName: "unregister",
                                method: .post,
                                parameters: parameters,
                                headers: self.defaultHeaders(),
                                success: { _ in
                                    if let success = success {
                                        success()
                                    }
        },
                                failure: failure)
    }
    
    /// Unregister the current device from all topics is registred to
    ///
    /// - Parameters:
    ///   - success: A block object to be executed when the task finishes successfully. This block has no return value and no arguments.
    ///   - failure: A block object to be executed when the task finishes unsuccessfully, or that finishes successfully, but the server encountered an error. This block has no return value and takes one argument: the error describing the error that occurred.
    @objc public static func unregisterFromAllTopics(success: (() -> Void)? = nil,
                                                     failure: ((_ error: Error?) -> Void)? = nil) {
        if token == nil {
            if let failure = failure {
                failure(tokenError())
            }
            return
        }
        
        MPushApiManager.callApi(withName: "unregister-all",
                                method: .post,
                                parameters: self.defaultParameters(),
                                headers: self.defaultHeaders(),
                                success: { _ in
                                    if let success = success {
                                        success()
                                    }
        },
                                failure: failure)
    }
    
    // MARK: Private functions
    
    /// Default headers used to call the apis
    ///
    /// - Returns: The default headers used to call the apis
    private static func defaultHeaders() -> [String: String] {
        var headers = ["Accept": "application/json",
                       "X-MPush-Version": "2"]
        if let token = token {
            headers["X-MPush-Token"] = token
        }
        return headers
    }
    
    /// Default parameters used to call the apis
    ///
    /// - Returns: The default parameters used to call the apis
    private static func defaultParameters() -> [String: String] {
        if let deviceIdString = self.deviceIdString() {
            return ["device_id": deviceIdString]
        }
        return [String: String]()
    }
    
    /// A string representing the device id
    ///
    /// - Returns: A string representing the device id
    private static func deviceIdString() -> String? {
        let userDefaults = UserDefaults(suiteName: "MPush")
        if let deviceIdString = userDefaults?.value(forKey: "device_id") as? String {
            return deviceIdString
        }
        if let deviceId = UIDevice.current.identifierForVendor {
            let deviceIdString = deviceId.uuidString
            userDefaults?.set(deviceIdString, forKey: "device_id")
            userDefaults?.synchronize()
            return deviceIdString
        }
        return nil
    }
    
    /// The error returned when token is not setted
    ///
    /// - Returns: The error returned when token is not setted
    private static func tokenError() -> Error {
        let error = MPushError(domain: "com.mumble.push", code: 100, message: "Token not setted")
        return error
    }
}
