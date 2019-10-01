//
//  MBParameters.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 24/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public struct URLParameterEncoder: ParameterEncoder {
    public enum Parameter {
        case queryItems
        case `default`
    }
    
    public static var queryItems: URLParameterEncoder { return URLParameterEncoder(method: .queryItems) }
    public static var `default`: URLParameterEncoder { return URLParameterEncoder() }
    
    public let parameter: Parameter
    
    public init(method: Parameter = .default) {
        parameter = method
    }
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else { throw MBError.invalidURL }
        
        if let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET"), canEncodeParametersInURL(method) {
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                urlComponents.queryItems = [URLQueryItem]()
                
                for (key,value) in parameters {
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
            
            urlRequest.httpBody = Data() // MARK: - complete this
            fatalError("x-www-form-urlencoded NOT implemented YET")
        }
    }
    
    private func canEncodeParametersInURL(_ method: HTTPMethod) -> Bool {
        switch parameter {
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

public struct JSONParameterEncoder: ParameterEncoder {
    public static var prettyPrinted: JSONParameterEncoder { return JSONParameterEncoder(method: .prettyPrinted) }
    public static var `default`: JSONParameterEncoder { return JSONParameterEncoder() }
    
    public let options: JSONSerialization.WritingOptions
    
    init(method: JSONSerialization.WritingOptions = []) {
        options = method
    }
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: options)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw MBError.encodingFailure
        }
    }
}
