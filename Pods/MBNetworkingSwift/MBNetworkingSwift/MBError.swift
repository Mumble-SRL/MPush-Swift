//
//  MBError.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 23/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation

/// An error of MBNetworking
public enum MBError: LocalizedError {
    /// The provided url is invalid
    /// - Parameters:
    ///   - url: the invalid url
    case invalidURL(url: URL)
    /// The request failed
    case requestFailed
    /// MBNetworking failed to decode the response
    case decodingFailure
    /// The response has some problems
    case responseFailure
    /// There was an error in the encoding process
    /// - Parameters:
    ///   - reason: the reason the validation has failed
    case encodingFailure(reason: String)
    /// There was an error in the validation process
    /// - Parameters:
    ///   - reason: the reason the validation has failed
    case validationFailure(reason: Int, data: Data?)
    /// A general custom error
    /// - Parameters:
    ///   - reason: the string representation of the error
    case customError(reason: String)
    /// Tried a multipart request with a method different from post
    case multipartWithMethodDifferentFromPost
    /// There was an error encoding multipart data
    /// - Parameters:
    ///   - reason: the `MultipartEncodingFailureReason`
    case multipartEncodingFailed(reason: MultipartEncodingFailureReason)
    
    /// The description of the error
    public var errorDescription: String? {
        switch self {
        case .invalidURL(url: let url):
            return "The provided url is invalid: \(url)"
        case .requestFailed:
            return "The request have failed"
        case .decodingFailure:
            return "Failed to decode the response"
        case .responseFailure:
            return "The response was found nil"
        case .encodingFailure(reason: let reason):
            return "An error occurred while trying to encode: " + reason
        case .validationFailure(reason: let reason):
            return "Validation failure; error: \(reason)"
        case .customError(reason: let reason):
            return "An error has occurred: " + reason
        case .multipartWithMethodDifferentFromPost:
            return "Error, multipart request can be accepted only with POST as HTTPMethod"
        case .multipartEncodingFailed(reason: let reason):
            return "An error while dealing with Multipart has occurred, reason: \(reason.failureDescription)"
        }
    }
}

/// This enum represents an error in the encoding of a multipart request
public enum MultipartEncodingFailureReason {
    /// The url is not valid
    /// - Parameters:
    ///   - url: the `URL`
    case bodyPartURLInvalid(url: URL)
    /// The file name is not valid
    /// - Parameters:
    ///   - inUrl: the `URL`
    case bodyPartFilenameInvalid(inUrl: URL)
    /// The file is not a file but a directory
    /// - Parameters:
    ///   - atUrl: the `URL`
    case bodyPartFileIsDirectory(atUrl: URL)
    /// The file is not in the directory
    /// - Parameters:
    ///   - for: the `URL`
    ///   - error: the `Error`
    case fileIsNotInDirectory(atUrl: URL, error: Error)
    /// The file at url already exists
    /// - Parameters:
    ///   - atUrl: the `URL`
    case fileAlreadyExists(atUrl: URL)
    /// The file url is invalid
    /// - Parameters:
    ///   - url: the `URL`
    case fileURLIsInvalid(url: URL)
    /// Couldn't read the Data
    /// - Parameters:
    ///   - error: the `Error` given
    case dataReadFailed(error: Error)
    
    var failureDescription: String {
        switch self {
        case .bodyPartURLInvalid(url: let url):
            return "The URL for the part is not valid: \(url.absoluteString)"
        case .bodyPartFilenameInvalid(inUrl: let url):
            return "The part's filename is not valid, url: \(url.absoluteString)"
        case .bodyPartFileIsDirectory(atUrl: let url):
            return "The URL \(url.absoluteString) is the directory URL"
        case .fileIsNotInDirectory(atUrl: let url, error: let error):
            return "Cannot remove the file at url: \(url.absoluteString), error: \(error.localizedDescription)"
        case .fileAlreadyExists(atUrl: let url):
            return "The file already exists at url: \(url.absoluteString)"
        case .fileURLIsInvalid(url: let url):
            return "The file at url: \(url.absoluteString) is invalid"
        case .dataReadFailed(error: let error):
            return "Couldn't read Data, error: \(error.localizedDescription)"
        }
    }
}
