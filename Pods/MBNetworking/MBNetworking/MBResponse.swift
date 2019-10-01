//
//  MBResponse.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import Foundation

public struct MBResponse<Value> {
    public let data: Data?
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let error: Error?
    public let result: MBResult<Value>
    
    init(request: URLRequest?,
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
    
    init(error: Error?,
         result: MBResult<Value>) {
        request = nil
        data = nil
        response = nil
        self.error = error
        self.result = result
    }
}
