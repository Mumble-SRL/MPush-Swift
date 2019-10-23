//
//  MBRequest.swift
//  MBNetworking
//
//  Created by Alessandro Viviani on 24/09/2019.
//  Copyright © 2019 Mumble s.r.l. (https://mumbleideas.it/).
//  All rights reserved.
//

import Foundation

// MARK: - Future optional implementation
protocol MBRequestProtocol {
    var baseUrl: URL { get }
    var method: HTTPMethod { get }
    var body: Parameters { get }
    var headers: [HTTPHeader]? { get }
}

/*
open class MBRequestUpload {
    enum Upload {
        case data(Data, URLRequest)
        case file(URL, URLRequest)
        
        func task(session: URLSession, queue: DispatchQueue) -> URLSessionTask {
            let task: URLSessionTask

            switch self {
            case let .data(data, urlRequest):
                task = queue.sync { session.uploadTask(with: urlRequest, from: data) }
            case let .file(url, urlRequest):
                task = queue.sync { session.uploadTask(with: urlRequest, fromFile: url) }
            }
            return task
        }
    }
}
*/
