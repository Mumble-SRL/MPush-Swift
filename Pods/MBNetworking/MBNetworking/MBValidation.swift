//
//  MBValidation.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    // MARK: - Implement all status codes with errors
    
    /// Validate the status code, if it's less than 200 and greater than 300 it returns an error
    func validateStatusCode() -> MBResult<Any>? {
        switch statusCode {
        case 200..<299:
            return nil
        default:
            return .error(MBError.validationFailure(reason: statusCode))
        }
    }
}
