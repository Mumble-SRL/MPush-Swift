//
//  MBParameters.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 24/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation

/// An alias for a dictionary where keys are strings and can have any value
public typealias Parameters = [String: Any]

/// Classes that implement this protocl will be responsible to encode parameters in a url request
public protocol ParameterEncoder {
    /// Encodes a dictionary of `Parameters` in an url request
    /// - Parameters:
    ///   - urlRequest: the `URLRequest` in wich the parameters will be encoded
    ///   - parameters: the `Parameters` that will be encoded in the request
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

// MARK: - URL encoding

/// Encode the parameter in the url string
public struct URLParameterEncoder: ParameterEncoder {
    /// The url encoding method
    public enum URLParameterEncodingMethod {
        /// Encode the parameter as query items in the url request
        case queryItems
        /// The default encoding method
        case `default`
    }
    
    /// The `URLParameterEncodingMethod` used to encode the parameters
    private let urlParameterEncodingMethod: URLParameterEncodingMethod

    /// An url parameter encoder with `queryItems` method
    public static var queryItems: URLParameterEncoder {
        return URLParameterEncoder(method: .queryItems)
    }
    
    /// An url parameter encoder with the `default` method
    public static var `default`: URLParameterEncoder {
        return URLParameterEncoder()
    }
    
    /// Initializes a new `URLParameterEncoder` with the given method
    /// - Parameters:
    ///   - method: the `URLParameterEncodingMethod` used to encode, default to `.default`
    public init(method: URLParameterEncodingMethod = .default) {
        self.urlParameterEncodingMethod = method
    }
    
    /// Encodes the parameters in the request
    /// - Parameters:
    ///   - urlRequest: the `URLRequest` in wich the parameters will be encoded
    ///   - parameters: the `Parameters` that will be encoded in the request
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else { throw MBError.requestFailed }
        
        if let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET"), canEncodeParametersInURL(method) {
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                urlComponents.queryItems = [URLQueryItem]()
                
                for (key, value) in parameters {
                    let queryItem = URLQueryItem(name: key,
                                                 value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                    urlComponents.queryItems?.append(queryItem)
                }
                urlRequest.url = urlComponents.url
            }
        } else {
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = Data() // TODO: - complete this
            fatalError("x-www-form-urlencoded NOT implemented YET")
        }
    }
    
    private func canEncodeParametersInURL(_ method: HTTPMethod) -> Bool {
        switch urlParameterEncodingMethod {
        case .queryItems:
            return true
        default:
            break
        }
        
        switch method {
        case .get, .delete:
            return true
        default:
            return false
        }
    }
}

// MARK: - JSON encoding

/// Encode the parameter in the body of the request as JSON
public struct JSONParameterEncoder: ParameterEncoder {
    
    /// The `JSONSerialization.WritingOptions` used to write the json
    public let options: JSONSerialization.WritingOptions
    
    /// A JSON parameter encoder with the `prettyPrinted` option
    public static var prettyPrinted: JSONParameterEncoder {
        return JSONParameterEncoder(options: .prettyPrinted)
    }
    
    /// A JSON parameter encoder with no particulary writing options
    public static var `default`: JSONParameterEncoder {
        return JSONParameterEncoder()
    }
        
    /// Initializes a new `JSONParameterEncoder` with the given writing options
    /// - Parameters:
    ///   - options: the `JSONSerialization.WritingOptions` used to encode, default to an empty array
    init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    /// Encodes the parameters in the request
    /// - Parameters:
    ///   - urlRequest: the `URLRequest` in wich the parameters will be encoded
    ///   - parameters: the `Parameters` that will be encoded in the request
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: options)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch let error {
            throw MBError.encodingFailure(reason: error.localizedDescription)
        }
    }
}
