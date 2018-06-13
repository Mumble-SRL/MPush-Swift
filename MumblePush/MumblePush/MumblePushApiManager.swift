//
//  MumblePushApiManager.swift
//  MumblePush
//
//  Created by Lorenzo Oliveto on 11/06/18.
//  Copyright © 2018 Mumble. All rights reserved.
//

import UIKit

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

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
                                 success: (([String: Any]) -> Void)? = nil,
                                 failure: ((Error?) -> Void)? = nil) {
        
    }
}
