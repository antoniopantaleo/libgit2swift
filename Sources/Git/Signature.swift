//
//  Signature.swift
//  Libgit2Swift
//
//  Created by Antonio on 07/06/25.
//

import Foundation

public struct Signature: Sendable {
    public let name: String
    public let email: String
    public let date: Date
    
    init(name: String, email: String, date: Date) {
        self.name = name
        self.email = email
        self.date = date
    }
}
