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
    private let path: URL
    
    deinit {
        git_libgit2_shutdown()
    }
    
    private init(_ path: URL) {
        git_libgit2_init()
        self.path = path
    }
    
    
    /// Open a git repository from a given path
    ///
    /// > The path must be a valid git repository, otherwise an error is thrown
    ///
    /// - Parameter path: The path where the repository is located
    public init(path: URL) async throws {
        self.init(path)
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
        self.init(path)
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
    
    /// Add a file to the index
    ///
    /// - Parameter file: The file to add
    public func add(_ file: URL) throws {
        var index: OpaquePointer?
        let indexError = git_repository_index(&index, repository)
        if indexError != GIT_OK.rawValue {
            let error = git_error_last().pointee.message
            throw GitError.add(message: String(cString: error!))
        }
        guard let filePath = file.path(relativeTo: path)?.path(percentEncoded: false) else {
            throw GitError.add(message: "No such file or directory \(file.path(percentEncoded: false))")
        }
        let addError = git_index_add_bypath(index, filePath)
        logger.log("Adding \(filePath) to the index")
        if addError != GIT_OK.rawValue {
            let error = git_error_last().pointee.message
            throw GitError.add(message: String(cString: error!))
        }
        let writeError = git_index_write(index)
        if writeError != GIT_OK.rawValue {
            let error = git_error_last().pointee.message
            throw GitError.add(message: String(cString: error!))
        }
        git_index_free(index)
    }
}
