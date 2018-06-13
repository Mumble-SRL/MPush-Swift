//
//  MumblePush.swift
//  MumblePush
//
//  Created by Lorenzo Oliveto on 11/06/18.
//  Copyright © 2018 Mumble. All rights reserved.
//

import UIKit

class MumblePush: NSObject {
    static var token: String?
    
    static func registerDevice(deviceToken: Data,
                               success: (() -> Void)? = nil,
                               failure: ((Error) -> Void)? = nil) {
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

        MumblePushApiManager.callApi(withName: "tokens",
                                     method: .post,
                                     parameters: parameters,
                                     headers: self.defaultHeaders())
    }
    
    static func register(toTopic topic: String,
                         success: (() -> Void)? = nil,
                         failure: ((Error) -> Void)? = nil) {
        self.register(toTopics: [topic])
    }
    
    static func register(toTopics topics: [String],
                         success: (() -> Void)? = nil,
                         failure: ((Error) -> Void)? = nil) {
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
        
        MumblePushApiManager.callApi(withName: "register",
                                     method: .post,
                                     parameters: parameters,
                                     headers: self.defaultHeaders())
    }
    
    static func unregister(fromTopic topic: String,
                           success: (() -> Void)? = nil,
                           failure: ((Error) -> Void)? = nil) {
        self.unregister(fromTopics: [topic])
        
    }
    
    static func unregister(fromTopics topics: [String],
                           success: (() -> Void)? = nil,
                           failure: ((Error) -> Void)? = nil) {
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
        
        MumblePushApiManager.callApi(withName: "unregister",
                                     method: .post,
                                     parameters: parameters,
                                     headers: self.defaultHeaders())
    }
    
    // MARK: Private functions
    
    private static func defaultHeaders() -> [String: String] {
        var headers = ["Accept": "applicar"]
        if let token = token {
            headers["X-MPush-Token"] = token
        }
        return headers
    }
    
    private static func defaultParameters() -> [String: String] {
        if let deviceId = UIDevice.current.identifierForVendor {
            return ["device_id": deviceId.uuidString]
        }
        return [String: String]()
    }
    
    private static func tokenError() -> Error {
        let error = MumblePushError.init(domain: "com.mumble.push", code: 100, message: "Token not setted")
        return error
    }
}
