//
//  MBResult.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation

/// The result that will be used by `MBNetworking` to call the completion blocks
public enum MBResult<Value> {
    /// The result was successful:
    /// - Parameters:
    ///   - Value: the value returned
    case success(Value)
    /// The result had some errors:
    /// - Parameters:
    ///   - Error: the error returned
    case error(Error)
}

/// The result that will be used by `MBNetworking` to call the completion blocks when doing a multipart request
public enum MBMultipartResponse {
    /// The result was successful:
    /// - Parameters:
    ///   - StatusCode: the status code returned
    case success(Int)
    /// The result had some errors:
    /// - Parameters:
    ///   - Error: the error returned
    case error(Error)
}
