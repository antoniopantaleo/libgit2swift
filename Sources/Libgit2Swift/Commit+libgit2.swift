//
//  Commit+libgit2.swift
//  Libgit2Swift
//
//  Created by Antonio on 07/06/25.
//

import Foundation
import libgit2

extension Commit {
    init?(pointer: OpaquePointer) {
        guard let messagePtr = git_commit_message(pointer) else {
            return nil
        }
        guard let hashPtr = git_commit_id(pointer) else {
            return nil
        }
        guard let authorPtr = git_commit_author(pointer) else {
            return nil
        }
        guard let committerPtr = git_commit_committer(pointer) else {
            return nil
        }
        
        let message = String(cString: messagePtr)
        let id = hashPtr.hash
        let author = authorPtr.signature
        let committer = committerPtr.signature
        
        let parentCount = git_commit_parentcount(pointer)
        var parentIds: [String] = []
        
        for i in 0..<parentCount {
            if let parentIdPtr = git_commit_parent_id(pointer, i) {
                parentIds.append(parentIdPtr.hash)
            }
        }
        
        self.init(
            id: id,
            message: message,
            author: author,
            committer: committer,
            parentIds: parentIds
        )
    }
    
}
