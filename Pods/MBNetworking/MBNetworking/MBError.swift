//
//  MBError.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import Foundation

public enum MBError: Error {
    case invalidURL
    case requestFailed
    case decodingFailure
    case responseProblem
    case encodingFailure
    case validationFailure(reason: Int)
    case customError(reason: String)
    case multipartWithMethodDifferentFromPost
    case multipartEncodingFailed(reason: MultipartEncodingFailureReason)
}

public enum MultipartEncodingFailureReason {
    case bodyPartURLInvalid(url: URL)
    case bodyPartFilenameInvalid(in: URL)
    case bodyPartFileNotReachable(at: URL)
    case bodyPartFileNotReachableWithError(atURL: URL, error: Error)
    case bodyPartFileIsDirectory(at: URL)
    case bodyPartFileSizeNotAvailable(at: URL)
    case bodyPartFileSizeQueryFailedWithError(forURL: URL, error: Error)
    case bodyPartInputStreamCreationFailed(for: URL)
    case fileIsNotInDirectory(at: URL, error: Error)
    
    case outputStreamCreationFailed(for: URL)
    case outputStreamFileAlreadyExists(at: URL)
    case outputStreamURLInvalid(url: URL)
    case outputStreamWriteFailed(error: Error)
    
    case inputStreamReadFailed(error: Error)
}
