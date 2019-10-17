//
//  MBMulitpartFormData.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 24/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation
import MobileCoreServices

/// All classes that will be sended as multipart requests must implement this protocol
public protocol MBMultipartFormProtocol {
    /// The name of the field
    var name: String { get }
    /// The `Data` that will be sent, this is optional, if this is not present the `fileUrl` property must have a value
    var data: Data? { get }
    /// The `URL` of a file that will be red and sent, this is optional, if this is not present the `data` property must have a value
    var fileUrl: URL? { get }
    /// The `mimeType` of the file, optional, this will be considered only if `fileUrl` has a value
    var mimeType: String? { get }
}

/// This class represents an object that will be uploaded using multipart method
open class MBMultipartForm: MBMultipartFormProtocol {
    /// The name of the field
    public var name: String
    
    /// The `Data` that will be sent, this is optional, if this is not present the `fileUrl` property must have a value
    public var data: Data?
    
    /// The `URL` of a file that will be red and sent, this is optional, if this is not present the `data` property must have a value
    public var fileUrl: URL?
    
    /// The `mimeType` of the file, optional, this will be considered only if `fileUrl` has a value
    public var mimeType: String?
    
    /// Initializes a `MBMultipartForm` with the name of the field and some data
    /// - Parameters:
    ///   - name: the `name` of the field
    ///   - data: the `Data` that will be sent
    public init(name: String,
                data: Data) {
        self.name = name
        self.data = data
    }
    
    /// Initializes a `MBMultipartForm` with the name of the field and a file
    /// - Parameters:
    ///   - name: the `name` of the field
    ///   - url: the `URL` of the file
    ///   - mimeType: the `mimeType` of the file
    public init(name: String,
                url: URL,
                mimeType: String? = nil) {
        self.name = name
        self.fileUrl = url
        self.mimeType = mimeType
    }
}

/// The result of the encoding of a multipart form
public enum MBMultipartEncodingResult {
    /// The encoder returns this value if it has encoded the form as data
    /// - Parameters:
    ///   Data: the data encoded
    case data(Data)
    /// The encoder returns this value if it has saved the form as a file
    /// - Parameters:
    ///   URL: the `URL` of the file saved
    case fileUrl(URL)
}

/// This class is responsible to create the body for a Multipart request
public class MBMulitpartFormManager {
    /// This value indicate the threshold used to discriminate between data or file.
    /// If this threshold is surpassed the data is saved in a temporary file that will be red only at encoding time
    public let multipartFormDataEncodingMemoryThreshold: UInt64 = 10_000_000
    
    /// The boundary used to separate the fields
    private var boundary: String {
        return "mumble.boundary"
    }
    
    private let lineBreak = "\r\n"
        
    /// The content of the data
    private var dataContentLenght: UInt64
    
    /// The queue used to save files
    private let queue = DispatchQueue(label: "com.mumble.multipartForm-manager." + UUID().uuidString)
    
    init() {
        // @TODO: - Future implementation
        // aggiornare ad ogni ciclo il campo dataContentLenght per poi effettuare il controllo
        dataContentLenght = 0
    }
    
    /// Encodes the parameters in the request, if something gives an error it throws an exception
    /// - Parameters:
    ///   - urlRequest: the `URLRequest` in wich the parameters will be encoded
    ///   - parameters: the array of `MBMultipartForm` that will be encoded in the request
    /// - Returns: The `MBMultipartEncodingResult` of the encoding.
    public func encode(urlRequest: inout URLRequest, with parameters: [MBMultipartForm]) throws -> MBMultipartEncodingResult {
        if let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET"), method == .post {
            
            do {
                let multipartData = try appendDatas(parameters)
                
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                }
                
                if UInt64(multipartData.count) > multipartFormDataEncodingMemoryThreshold {
                    let url = try createDirectoryAndWriteFile(multipartData)
                    return MBMultipartEncodingResult.fileUrl(url)
                } else {
                    return MBMultipartEncodingResult.data(multipartData)
                }
            } catch let error {
                throw MBError.multipartEncodingFailed(reason: MultipartEncodingFailureReason.dataReadFailed(error: error))
            }
            
        } else {
            throw MBError.multipartWithMethodDifferentFromPost
        }
    }
    
    private func appendDatas(_ params: [MBMultipartForm]) throws -> Data {
        var body = Data()
        
        for form in params {
            if let data = form.data {
                appendData(data, withName: form.name, body: &body)
            } else if let fileUrl = form.fileUrl {
                if let mimeType = form.mimeType {
                    try appendUrl(fileUrl, withName: form.name, mimeType: mimeType, fileName: fileUrl.lastPathComponent, body: &body)
                } else {
                    try appendUrl(fileUrl, withName: form.name, body: &body)
                }
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    private func appendData(_ data: Data, withName name: String, body: inout Data) {
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\(lineBreak + lineBreak)")
        body.append(data)
        body.append(lineBreak)
    }
    
    private func appendUrl(_ url: URL, withName name: String, body: inout Data) throws {
        let fileName = url.lastPathComponent
        let pathExtension = url.pathExtension
        
        if !name.isEmpty && !pathExtension.isEmpty {
            let mime = mimeType(forPathExtension: pathExtension)
            
            try appendUrl(url, withName: name, mimeType: mime, fileName: fileName, body: &body)
        } else {
            throw MBError.multipartEncodingFailed(reason: .bodyPartFilenameInvalid(inUrl: url))
        }
    }
    
    private func appendUrl(_ url: URL, withName name: String, mimeType: String, fileName: String, body: inout Data) throws {
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\(lineBreak)")
        body.append("Content-Type: \(mimeType + lineBreak + lineBreak)")
        do {
            let dataOfUrl = try Data(contentsOf: url)
            body.append(dataOfUrl)
            body.append(lineBreak)
        } catch {
            throw MBError.multipartEncodingFailed(reason: .bodyPartFilenameInvalid(inUrl: url))
        }
    }
    
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if let mimeType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(mimeType, kUTTagClassMIMEType)?.takeRetainedValue() {
            return contentType as String
        }
        return "application/octet-stream"
    }
    
    private func createDirectoryAndWriteFile(_ data: Data) throws -> URL {
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let directoryURL = tempDirectoryURL.appendingPathComponent("com.mumble.mbmultipart/multipart.form.data")
        let fileName = UUID().uuidString
        let fileURL = directoryURL.appendingPathComponent(fileName)
        
        var directoryError: Error?
        self.queue.sync {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                directoryError = MBError.multipartEncodingFailed(reason: MultipartEncodingFailureReason.bodyPartFileIsDirectory(atUrl: directoryURL))
            }
        }
        
        if let directoryError = directoryError { throw directoryError }
        
        try writeData(data, to: fileURL)
        
        return fileURL
    }
    
    private func writeData(_ data: Data, to fileURL: URL) throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            throw MBError.multipartEncodingFailed(reason: .fileAlreadyExists(atUrl: fileURL))
        } else if !fileURL.isFileURL {
            throw MBError.multipartEncodingFailed(reason: .fileURLIsInvalid(url: fileURL))
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            throw MBError.customError(reason: error.localizedDescription)
        }
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
