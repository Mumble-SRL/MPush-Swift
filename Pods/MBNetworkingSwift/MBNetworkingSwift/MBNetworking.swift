//
//  MBClient.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import UIKit

/// The header of an HTTP request.
public struct HTTPHeader {
    
    /// The field header used as a key in the headers dictionary.
    public let field: String
    
    /// The value of the header.
    public let value: String
    
    /// Initializes a new header with the field and value provided.
    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}

/// The method of an HTTP request
public enum HTTPMethod: String {
    /// GET method
    case get = "GET"
    /// PUT method
    case put = "PUT"
    /// POST method
    case post = "POST"
    /// DELETE method
    case delete = "DELETE"
    // @TODO: - Support more methods
//    case patch = "PATCH"
}

/// This class is your entry point to do requests with MBNetworking
public struct MBNetworking {
    
    /// The url session used to make requests
    private static let session = URLSession.shared
        
    /// Makes a request using MBNetwroking
    /// - Parameters:
    ///   - urlString: The `urlString` value
    ///   - method: The `HTTPMethod` of the request, `.get` by default
    ///   - headers: The headers for the request, `nil` by default
    ///   - parameters: The parameters for the request, `nil` by default, its an alias for `[String: Any]`
    ///   - encoding: An object that implements `ParameterEncoder`, used to encode the parameters
    ///   - completion: A completion block that will be called when the request finishes, successfully or with error, the block will have a parameter (the `MBResponse`) and will return no value, the block will be called in the main thread.

    public static func request(withUrl urlString: String,
                               method: HTTPMethod = .get,
                               headers: [HTTPHeader]? = nil,
                               parameters: Parameters? = nil,
                               encoding: ParameterEncoder,
                               _ completion: @escaping (MBResponse<Any>) -> Void) {
        precondition(!urlString.isEmpty, "url not setted")
        
        guard let url = URL(string: checkUrlName(urlString)) else { return }
      
        do {
            let urlRequest = try buildUrlRequest(url, method: method, headers: headers, parameters: parameters, encoding: encoding)
            
            session.dataTask(with: urlRequest) { (data, urlResponse, error) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else { return }
                
                if let validationFailed = httpResponse.validateStatusCode(data: data) {
                    DispatchQueue.main.async {
                        completion(MBResponse<Any>(request: urlRequest, data: data, response: httpResponse, error: error, result: validationFailed))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(MBResponse<Any>(request: urlRequest, data: data, response: httpResponse, error: error, result: extractJSON(data)))
                    }
                }
            }.resume()
        } catch let error {
            DispatchQueue.main.async {
                completion(MBResponse<Any>(error: error, result: MBResult.error(error)))
            }
        }
    }
    
    /// Makes a multipart POST request using MBNetwroking
    /// - Parameters:
    ///   - urlString: The `urlString` value
    ///   - headers: The headers for the request, `nil` by default
    ///   - parameters: an array of `MBMultipartForm` objects that will be sent with the response, by default its an empty array
    ///   - encoding: An object that implements `ParameterEncoder`, used to encode the parameters
    ///   - completion: A completion block that will be called when the request finishes, successfully or with error, the block will have a parameter (the `MBMultipartResponse`) and will return no value, the block will be called in the main thread.
    
    public static func upload(toUrl urlString: String,
                              headers: [HTTPHeader]?,
                              parameters: [MBMultipartForm] = [],
                              completion: @escaping((MBMultipartResponse) -> Void)) {
        precondition(!urlString.isEmpty, "url not setted")
        
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: checkUrlName(urlString)) else { return }
            let multipartManager = MBMulitpartFormManager()
            do {
                let multipartResult = try buildUploadRequest(url, method: .post, multipart: parameters, manager: multipartManager, headers: headers)
                
                switch multipartResult.result {
                case .data(let data):
                    session.uploadTask(with: multipartResult.request, from: data) { (data, response, error) in
                        let parsedResponse = parseResponse(data, error: error, response: response, fileUrl: nil)
                        DispatchQueue.main.async {
                            completion(parsedResponse)
                        }
                    }.resume()
                case .fileUrl(let url):
                    session.uploadTask(with: multipartResult.request, fromFile: url) { (data, response, error) in
                        let parsedResponse = parseResponse(data, error: error, response: response, fileUrl: url)
                        DispatchQueue.main.async {
                            completion(parsedResponse)
                        }
                    }.resume()
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.error(error))
                }
            }
        }
    }
    
    private static func checkUrlName(_ name: String) -> String {
        var nameCopy = name
        if nameCopy.hasPrefix("/") {
            nameCopy.remove(at: nameCopy.startIndex)
        }
        
        if nameCopy.hasSuffix("/") {
            nameCopy.remove(at: nameCopy.index(before: nameCopy.endIndex))
        }
        return nameCopy
    }
    
    private static func extractJSON(_ data: Data?) -> MBResult<Any> {
        guard let unwrappedData = data else {
            return .error(MBError.decodingFailure)
        }
        do {
            let json = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
            return .success(json)
        } catch let error {
            return .error(error)
        }
    }
    
    fileprivate static func buildUrlRequest(_ url: URL,
                                            method: HTTPMethod,
                                            headers: [HTTPHeader]?,
                                            parameters: Parameters?,
                                            encoding: ParameterEncoder) throws -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
        
        request.httpMethod = method.rawValue
        
        addHeaders(headers, request: &request)
        
        try encoding.encode(urlRequest: &request, with: parameters ?? Parameters())
        return request
    }
    
    fileprivate static func buildUploadRequest(_ url: URL,
                                               method: HTTPMethod,
                                               multipart: [MBMultipartForm] = [],
                                               manager: MBMulitpartFormManager,
                                               headers: [HTTPHeader]?) throws -> (request: URLRequest, result: MBMultipartEncodingResult) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
        
        request.httpMethod = method.rawValue
        
        addHeaders(headers, request: &request)
        
        let result = try manager.encode(urlRequest: &request, with: multipart)
    
        return (request, result)
    }
    
    fileprivate static func addHeaders(_ headers: [HTTPHeader]?, request: inout URLRequest) {
        guard let unwrappedHeaders = headers, unwrappedHeaders.count != 0 else { return }
        
        unwrappedHeaders.forEach { request.addValue($0.value, forHTTPHeaderField: $0.field) }
    }
    
    fileprivate static func parseResponse(_ data: Data?, error: Error?, response: URLResponse?, fileUrl: URL?) -> MBMultipartResponse {
        defer {
            if let url = fileUrl {
                removeFile(at: url)
            }
        }
        
        guard error == nil else {
            return .error(error!)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .error(MBError.responseFailure)
        }
        
        return .success(httpResponse.statusCode)
    }
    
    fileprivate static func removeFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
             print(MBError.multipartEncodingFailed(reason: .fileIsNotInDirectory(atUrl: url, error: error)))
        }
    }
}

/*
 
extension Dictionary where Key == StringLiteralType, Value: Any {
    func serialized() -> Data? {
        do {
            let serializedData = try JSONSerialization.data(withJSONObject: self, options: [])
            if let stringSerialzied = String(data: serializedData, encoding: .utf8) {
                return stringSerialzied.data(using: .utf8)
            }
            return serializedData
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
*/
