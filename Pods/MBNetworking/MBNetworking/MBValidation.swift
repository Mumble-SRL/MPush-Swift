//
//  MBValidation.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import Foundation


extension HTTPURLResponse {
    // MARK: - Implement all status codes with errors
    func validateStatusCode() -> MBResult<Any>? {
        switch statusCode {
        case 200..<299:
            return nil
        default:
            return .error(MBError.validationFailure(reason: statusCode))
        }
    }
}
