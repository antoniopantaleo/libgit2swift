//
//  Repository.swift
//
//
//  Created by Antonio Pantaleo on 12/06/24.
//

import os
import Foundation
import libgit2

/// A git repository
public actor Repository {
    
    private let logger = Logger(category: "Repository")
    private var repository: OpaquePointer?
    
    deinit {
        git_libgit2_shutdown()
    }
    
    private init() {
        git_libgit2_init()
    }
    
    
    /// Open a git repository from a given path
    ///
    /// > The path must be a valid git repository, otherwise an error is thrown
    ///
    /// - Parameter path: The path where the repository is located
    public init(path: URL) async throws {
        self.init()
        let exitCode = git_repository_open(&repository, path.path())
        if exitCode != GIT_OK.rawValue {
            let error = git_error_last().pointee.message
            throw GitError.clone(message: String(cString: error!))
        }
        if let repoDir = git_repository_path(repository) {
            logger.info("Repository opened at \(String(cString: repoDir))")
        }
    }

    
    /// Clone a git repository from a given URL
    ///
    /// > The path must be a valid git repository, otherwise an error is thrown
    ///
    /// - Parameters:
    ///   - repo: The URL of the repository to clone
    ///   - path: The path where to clone the repository
    public init(clone repo: URL, path: URL) async throws {
        self.init()
        let now = Date.now
        logger.info("Prepare to clone repo \(repo)")
        let exitCode = git_clone(&repository, repo.absoluteString, path.path(), nil)
        logger.info("Finished cloning \(repo) in \(now.distance(to: Date.now))")
        if exitCode != GIT_OK.rawValue {
            let error = git_error_last().pointee.message
            throw GitError.clone(message: String(cString: error!))
        }
        if let repoDir = git_repository_path(repository) {
            logger.info("Repository cloned at \(String(cString: repoDir))")
        }
    }

    
    
    /// Get the logs of the repository
    ///
    /// - Returns: An array of logs
    public func log() async throws -> [Log] {
        var logs = [Log]()
        var walker: OpaquePointer?
        git_revwalk_new(&walker, repository)
        git_revwalk_push_head(walker)
        git_revwalk_sorting(walker, GIT_SORT_TOPOLOGICAL.rawValue | GIT_SORT_REVERSE.rawValue)
        var oid = git_oid()
        while git_revwalk_next(&oid, walker) == GIT_OK.rawValue {
            var commit: OpaquePointer?
            git_commit_lookup(&commit, repository, &oid)
            guard let message = git_commit_message(commit) else {
                throw  GitError.log(message: "No message")
            }
            let stringMessage = String(cString: message)
            let log = Log(message: stringMessage)
            logs.append(log)
            git_commit_free(commit)
        }
        git_revwalk_free(walker)
        return logs
        
        
    }
}
