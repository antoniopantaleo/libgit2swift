//
//  Repository.swift
//
//
//  Created by Antonio Pantaleo on 12/06/24.
//

import os
import Foundation
import libgit2

public actor Repository {
    
    private let logger = Logger(category: "Repository")
    private let STATUS_CODE_OK = 0
    private var repository: OpaquePointer?
    
    deinit {
        git_repository_free(repository)
        git_libgit2_shutdown()
    }
    
    private init() {
        git_libgit2_init()
    }
    
    public init(path: URL) async throws {
        self.init()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                let exitCode = git_repository_open(&repository, path.path())
                if exitCode != STATUS_CODE_OK {
                    let error = git_error_last().pointee.message
                    return continuation.resume(throwing: GitError.clone(message: String(cString: error!)))
                }
                if let repoDir = git_repository_path(repository) {
                    logger.info("Repository opened at \(String(cString: repoDir))")
                }
                continuation.resume()
            }
        }
    }
    
    public init(clone repo: URL, path: URL) async throws {
        self.init()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                let now = Date.now
                logger.info("Prepare to clone repo \(repo)")
                let exitCode = git_clone(&repository, repo.absoluteString, path.path(), nil)
                logger.info("Finished cloning \(repo) in \(now.distance(to: Date.now))")
                if exitCode != STATUS_CODE_OK {
                    let error = git_error_last().pointee.message
                    return continuation.resume(throwing: GitError.clone(message: String(cString: error!)))
                }
                if let repoDir = git_repository_path(repository) {
                    logger.info("Repository cloned at \(String(cString: repoDir))")
                }
                continuation.resume()
            }
        }
    }
}
