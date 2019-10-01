//
//  MBResult.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import Foundation

public enum MBResult<Value> {
    case success(Value)
    case error(Error)
}

public enum MBMultipartResponse {
    case success(Int)
    case error(Error)
}

