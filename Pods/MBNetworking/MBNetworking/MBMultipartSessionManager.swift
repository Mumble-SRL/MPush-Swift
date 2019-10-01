//
//  MBMultipartSessionManager.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 24/09/2019.
//  Copyright © 2019 Alessadro Viviani. All rights reserved.
//

import Foundation

/*
class MBMultipartSessionManager {
    public static let multipartFormDataEncodingMemoryThreshold: UInt64 = 10_000_000
    let queue = DispatchQueue(label: "org.alamofire.session-manager." + UUID().uuidString)
    let session = URLSession.shared
    
    public enum MultipartResult {
        case success(fileUrl: URL?, fromDisk: Bool)
        case error(Error)
    }
    
    open func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = multipartFormDataEncodingMemoryThreshold,
        to url: URL,
        headers: [HTTPHeader]? = nil,
        queue: DispatchQueue? = nil
//        encodingCompletion: ((MultipartFormDataEncodingResult) -> Void)?)
    ) {
        do {
            let urlRequest = try URLRequest(url: url, method: .post, headers: headers)
            
            return upload(
                multipartFormData: multipartFormData,
                usingThreshold: encodingMemoryThreshold,
                with: urlRequest,
                queue: queue
//                encodingCompletion: encodingCompletion
            )
        } catch {
            (queue ?? DispatchQueue.main).async { /*encodingCompletion?(.failure(error))*/ }
        }
    }
    
    open func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = multipartFormDataEncodingMemoryThreshold,
        with urlRequest: URLRequest,
        queue: DispatchQueue? = nil,
        encodingCompletion: ((MultipartResult) -> Void)?) {
        DispatchQueue.global(qos: .utility).async {
            let formData = MultipartFormData()
            multipartFormData(formData)
            
            var tempFileURL: URL?
            var urlRequestWithContentType = urlRequest
            
            do {
                urlRequestWithContentType.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
                
                let isBackgroundSession = URLSession().configuration.identifier != nil
                
                if formData.contentLength < encodingMemoryThreshold && !isBackgroundSession {
                    let data = try formData.encode()
                    
                    let result = MultipartResult.success(fileUrl: nil, fromDisk: false)
                    
                    (queue ?? DispatchQueue.main).async { encodingCompletion?(result) }
                } else {
                    let fileManager = FileManager.default
                    let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    let directoryURL = tempDirectoryURL.appendingPathComponent("mbnetworking/multipart.form.data")
                    let fileName = UUID().uuidString
                    let fileURL = directoryURL.appendingPathComponent(fileName)
                    
                    tempFileURL = fileURL
                    
                    var directoryError: Error?
                    
                    // Create directory inside serial queue to ensure two threads don't do this in parallel
                    self.queue.sync {
                        do {
                            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            directoryError = error
                        }
                    }
                    
                    if let directoryError = directoryError { throw directoryError }
                    
                    try formData.writeEncodedData(to: fileURL)
                    
                    let upload = self.upload(fileURL, with: urlRequestWithContentType)
                    
                    // Cleanup the temp file once the upload is complete
                    upload.delegate.queue.addOperation {
                        self.removeFile(at: fileURL)
                    }
                    
                    (queue ?? DispatchQueue.main).async {
                        let result = MultipartResult.success(fileUrl: tempFileURL, fromDisk: true)
                        encodingCompletion?(result)
                    }
                    
                }
            } catch {
                // Cleanup the temp file in the event that the multipart form data encoding failed
                if let unwrappedFileUrl = tempFileURL {
                    self.removeFile(at: unwrappedFileUrl)
                }
                
                (queue ?? DispatchQueue.main).async { encodingCompletion?(.failure(error)) }
            }
        }
    }
    
    open func upload(_ fileURL: URL, with urlRequest: URLRequest) -> MBRequestUpload {
        return upload(.file(fileURL, urlRequest))
    }
    
    private func upload(_ uploadable: MBRequestUpload.Upload) -> MBRequestUpload {
        do {
            let task = try uploadable.task(session: session, queue: queue)
            let upload = UploadRequest(session: session, requestTask: .upload(uploadable, task))

            delegate[task] = upload

            if startRequestsImmediately { upload.resume() }

            return upload
        } catch {
            return upload(uploadable, failedWith: error)
        }
    }
    
    // remove the temporary file after completion or failure
    fileprivate func removeFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error {
            // cannot remove item
            print(error.localizedDescription)
        }
    }
}

 */
