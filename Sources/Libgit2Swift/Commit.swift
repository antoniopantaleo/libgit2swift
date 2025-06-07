//
//  Commit.swift
//  Libgit2Swift
//
//  Created by Antonio on 07/06/25.
//

import Foundation

public struct Commit: Identifiable, Sendable {
    public let id: String
    public let message: String
    public let author: Signature
    public let committer: Signature
    public let parentIds: [String]
    
    init(
        id: String,
        message: String,
        author: Signature,
        committer: Signature,
        parentIds: [String] = []
    ) {
        self.id = id
        self.message = message.trimmingCharacters(in: .newlines)
        self.author = author
        self.committer = committer
        self.parentIds = parentIds
    }
}
