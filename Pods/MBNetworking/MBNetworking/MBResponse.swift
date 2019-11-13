//
//  MBResponse.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation

/// This struct represnts a response that will be returned in the completion block of a request done by `MBNetworking`
public struct MBResponse<Value> {
    /// The raw `Data` returned
    public let data: Data?
    /// The `URLRequest` that originated the response
    public let request: URLRequest?
    /// The `HTTPURLResponse` returned
    public let response: HTTPURLResponse?
    /// If there was an error, this property will have the description
    public let error: Error?
    /// The `MBResult` of the request
    public let result: MBResult<Value>
    
    /// Initializes a response with the given data
    /// - Parameters:
    ///   - request: The `URLRequest` that originated this response
    ///   - data: The raw `Data` returned
    ///   - response: The `HTTPURLResponse` returned
    ///   - error: The `Error` returned, if present
    ///   - result: The `MBResult` of the request
    public init(request: URLRequest?,
                data: Data?,
                response: HTTPURLResponse?,
                error: Error?,
                result: MBResult<Value>) {
        self.data = data
        self.request = request
        self.response = response
        self.error = error
        self.result = result
    }
    
    /// Initializes a failed response
    /// - Parameters:
    ///   - error: The `Error` returned, if present
    ///   - result: The `MBResult` of the request
    public init(error: Error?,
                result: MBResult<Value>) {
        request = nil
        data = nil
        response = nil
        self.error = error
        self.result = result
    }
}
