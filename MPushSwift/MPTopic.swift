//
//  MPTopic.swift
//  MPushSwift
//
//  Created by Lorenzo Oliveto on 24/07/2020.
//  Copyright © 2020 Mumble. All rights reserved.
//

import UIKit

/// An MPush topic
public class MPTopic: NSObject {
    
    /// The code identifier of the topic
    public let code: String!

    /// An optional title for the topic, if not set the code will be used
    public let title: String!
    
    /// If the topic identify a single user or a group of users, defaults to false
    public let single: Bool!
    
    /// Initializes a new MPush topic with the data passed
    /// - Parameters:
    ///   - code: The code of the topic
    ///   - name: The name of the topic
    ///   - single: If the topic identify a single user or a group of users
    public init(_ code: String!,
                title: String? = nil,
                single: Bool? = nil) {
        self.code = code
        if let title = title {
            self.title = title
        } else {
            self.title = code
        }
        if let single = single {
            self.single = single
        } else {
            self.single = false
        }
    }
}
