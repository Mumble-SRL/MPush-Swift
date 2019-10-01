//
//  MBClient.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import UIKit

public struct HTTPHeader {
    public let field: String
    public let value: String
    
    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    // MARK: - Support more methods
//    case patch = "PATCH"
}

public struct MBNetworking {
    private static let session = URLSession.shared
    
    private(set) static var method: HTTPMethod = .get
    
    public static func request(withUrl urlString: String,
                               method: HTTPMethod,
                               headers: [HTTPHeader]? = nil,
                               parameters: Parameters? = nil,
                               encoding: ParameterEncoder,
                               _ completion: @escaping (MBResponse<Any>) -> Void)
    {
        precondition(!urlString.isEmpty, "url not setted")
        self.method = method
        
        guard let url = URL(string: checkUrlName(urlString)) else { return }
      
        do {
            let urlRequest = try buildUrlRequest(url, headers: headers, parameters: parameters, encoding: encoding)
            
            session.dataTask(with: urlRequest) { (data, urlResponse, error) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else { return }
                
                if let validationFailed = httpResponse.validateStatusCode() {
                    completion(MBResponse<Any>(request: urlRequest, data: data, response: httpResponse, error: error, result: validationFailed))
                }
                
                completion(MBResponse<Any>(request: urlRequest, data: data, response: httpResponse, error: error, result: extractJSON(data)))
            }.resume()
        } catch let error {
            completion(MBResponse<Any>(error: error, result: MBResult.error(error)))
        }
    }
    
    public static func upload(toUrl urlString: String,
                              headers: [HTTPHeader]?,
                              parameters: [MBMultipartForm],
                              completion: @escaping((MBMultipartResponse) -> Void)
                              )
    {
        precondition(!urlString.isEmpty, "url not setted")
        method = .post
        
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: checkUrlName(urlString)) else { return }
            let multipartManager = MBMulitpartFormManager()
            do {
                let multipartResult = try buildUploadRequest(url, multipart: parameters, manager: multipartManager, headers: headers)
                
                switch multipartResult.result {
                case .data(let data):
                    session.uploadTask(with: multipartResult.request, from: data) { (data, response, error) in
                        let parsedResponse = parseResponse(data, error: error, response: response, fileUrl: nil)
                        completion(parsedResponse)
                    }.resume()
                case .filUrl(let url):
                    session.uploadTask(with: multipartResult.request, fromFile: url) { (data, response, error) in
                        let parsedResponse = parseResponse(data, error: error, response: response, fileUrl: url)
                        completion(parsedResponse)
                    }.resume()
                }
            } catch let error {
                completion(.error(error))
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
                                               multipart: [MBMultipartForm],
                                               manager: MBMulitpartFormManager,
                                               headers: [HTTPHeader]?) throws -> (request: URLRequest, result: MBMulitpartFormManager.MultipartResult) {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20.0)
        
        request.httpMethod = method.rawValue
        
        addHeaders(headers, request: &request)
        
        let result = try manager.encode(urlRequest: &request, with: multipart)
    
        return (request, result)
    }
    
    fileprivate static func addHeaders(_ headers: [HTTPHeader]?, request: inout URLRequest) {
        guard let unwrappedHeaders = headers, unwrappedHeaders.count != 0 else { return }
        
        unwrappedHeaders.forEach{ request.addValue($0.value, forHTTPHeaderField: $0.field) }
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
            return .error(MBError.responseProblem)
        }
        
        return .success(httpResponse.statusCode)
    }
    
    fileprivate static func removeFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
             print(MBError.multipartEncodingFailed(reason: .fileIsNotInDirectory(at: url, error: error)))
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
