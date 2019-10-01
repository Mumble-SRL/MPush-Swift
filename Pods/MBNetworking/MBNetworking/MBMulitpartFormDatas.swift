//
//  MBMulitpartFormData.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 24/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import Foundation
import MobileCoreServices

public protocol MBMultipartFormProtocol {
    var name: String { get }
    var data: Data? { get }
    var fileUrl: URL? { get }
    var mimeType: String? { get }
}

open class MBMultipartForm: MBMultipartFormProtocol {
    public var name: String
    
    public var data: Data?
    
    public var fileUrl: URL?
    
    public var mimeType: String?
    
    init(name: String,
         data: Data)
    {
        self.name = name
        self.data = data
        self.mimeType = ""
    }
    
    init(name: String,
         url: URL,
         type: String)
    {
        self.name = name
        self.fileUrl = url
        self.mimeType = type
    }
}

public class MBMulitpartFormManager {
    public let multipartFormDataEncodingMemoryThreshold: UInt64 = 10_000_000
    
    private var boundary: String {
        return "mumble.boundary"
    }
    
    private let lineBreak = "\r\n"
    
    public enum MultipartResult {
        case data(Data)
        case filUrl(URL)
    }
    
    private var dataContentLenght: UInt64
    
    let queue = DispatchQueue(label: "com.mumble.multipartForm-manager." + UUID().uuidString)
    
    init() {
        // MARK: - Maybe Future implementation
        // aggiornare ad ogni ciclo il campo dataContentLenght per poi effettuare il controllo
        dataContentLenght = 0
    }
    
    public func encode(urlRequest: inout URLRequest, with parameters: [MBMultipartForm]) throws -> MultipartResult {
        if let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET"), method == .post {
            
            do {
                let multipartData = try appendDatas(parameters)
                
                if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                    urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                }
                
                if UInt64(multipartData.count) > multipartFormDataEncodingMemoryThreshold {
                    let url = try createDirectoryAndWriteFile(multipartData)
                    return MultipartResult.filUrl(url)
                } else {
                    return MultipartResult.data(multipartData)
                }
            } catch let error {
                throw MBError.multipartEncodingFailed(reason: MultipartEncodingFailureReason.inputStreamReadFailed(error: error))
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
            throw MBError.multipartEncodingFailed(reason: .bodyPartFilenameInvalid(in: url))
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
            throw MBError.multipartEncodingFailed(reason: .bodyPartFilenameInvalid(in: url))
        }
    }
    
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue() {
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
                directoryError = MBError.multipartEncodingFailed(reason: MultipartEncodingFailureReason.bodyPartFileIsDirectory(at: directoryURL))
            }
        }
        
        if let directoryError = directoryError { throw directoryError }
        
        try writeData(data, to: fileURL)
        
        return fileURL
    }
    
    func writeData(_ data: Data, to fileURL: URL) throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            throw MBError.multipartEncodingFailed(reason: .outputStreamFileAlreadyExists(at: fileURL))
        } else if !fileURL.isFileURL {
            throw MBError.multipartEncodingFailed(reason: .outputStreamURLInvalid(url: fileURL))
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
