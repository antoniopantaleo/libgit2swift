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
    
    public func log() async throws -> [Log] {
        try await withThrowingTaskGroup(of: Log?.self, returning: [Log].self) { [weak self] group in
            guard let repository = await self?.repository else { throw GitError.log(message: "Failed to read repository") }
            var logs = [Log]()
            var walker: OpaquePointer?
            git_revwalk_new(&walker, repository)
            let oid = git_object_id(repository)
            git_revwalk_push_head(walker)
            git_revwalk_sorting(walker, GIT_SORT_TOPOLOGICAL.rawValue | GIT_SORT_REVERSE.rawValue)
            while git_revwalk_next(UnsafeMutablePointer(mutating: oid), walker) == STATUS_CODE_OK {
                group.addTask { [weak self] in
                    guard let repository = await self?.repository else { throw GitError.log(message: "Failed to read repository") }
                    var commit: OpaquePointer?
                    git_commit_lookup(&commit, repository, oid)
                    guard let message = git_commit_message(commit) else {
                        throw GitError.log(message: "No message")
                    }
                    let stringMessage = String(cString: message)
                    let log = Log(message: stringMessage)
                    return log
                }
                
                for try await log in group {
                    if let log = log {
                        logs.append(log)
                    }
                }
            }
            return logs
        }
    }
}
