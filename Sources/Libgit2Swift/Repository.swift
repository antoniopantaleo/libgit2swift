//
//  Repository.swift
//
//
//  Created by Antonio Pantaleo on 12/06/24.
//

import Foundation
import os
import Libgit2Package

let STATUS_CODE_OK = 0

enum GitError: Swift.Error {
    case clone(message: String)
}

public actor Repository {
    
    private let logger = Logger(subsystem: "com.antoniopantaleo.Libgit2Swift", category: "Repository")
    
    private var repository: OpaquePointer?
    
    public init?(path: String) {
        git_libgit2_init()
        let exitCode = git_repository_open(&repository, path)
        if exitCode != STATUS_CODE_OK { return nil }
        git_libgit2_shutdown()
    }
    
    public init(clone: URL, path: URL) async throws {
        git_libgit2_init()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                let exitCode = git_clone(&repository, clone.absoluteString, path.path(), nil)
                if exitCode != STATUS_CODE_OK {
                    let error = git_error_last().pointee.message
                    return continuation.resume(throwing: GitError.clone(message: String(cString: error!)))
                }
                if let repoDir = git_repository_path(repository) {
                    logger.info("Repository cloned at \(String(cString: repoDir))")
                }
                git_libgit2_shutdown()
                continuation.resume()
            }
        }
    }
}
