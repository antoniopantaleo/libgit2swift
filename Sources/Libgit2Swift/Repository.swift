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
    private var repository: OpaquePointer!
    private let path: URL
    
    deinit {
        git_libgit2_shutdown()
    }
    
    private init(_ path: URL) {
        self.path = path
        git_libgit2_init()
    }
    
    
    /// Open a git repository from a given path
    ///
    /// > The path must be a valid git repository, otherwise an error is thrown
    ///
    /// - Parameter path: The path where the repository is located
    public init(path: URL) async throws {
        self.init(path)
        try execute(git_repository_open(&repository, path.path()))
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
        try execute(git_clone(&repository, repo.absoluteString, path.path(), nil))
        logger.info("Finished cloning \(repo) in \(now.distance(to: Date.now))")
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
        try execute(git_repository_index(&index, repository))
        
        guard let filePath = file.path(relativeTo: path)?.path(percentEncoded: false) else {
            throw GitError.add(message: "No such file or directory \(file.path(percentEncoded: false))")
        }
        
        try execute(git_index_add_bypath(index, filePath))
        logger.log("Adding \(filePath) to the index")
        try execute(git_index_write(index))
        git_index_free(index)
    }
    
    public func commit(message: String) throws {
        var index: OpaquePointer?
        var treeOid = git_oid()
        var tree: OpaquePointer?
        
        try execute(git_repository_index(&index, repository))
        let entryCount = git_index_entrycount(index)
        if entryCount == 0 {
            throw GitError.commit(message: "Empty index")
        }
        
        try execute(git_index_write_tree(&treeOid, index))
        git_index_free(index)
        
        try execute(git_tree_lookup(&tree, repository, &treeOid))
        var signature: UnsafeMutablePointer<git_signature>? = nil
        let configSnapshot = ConfigSnapshot(repository: repository)

        guard let name = configSnapshot.userName, let email = configSnapshot.userEmail else {
            throw GitError.commit(message: "No user")
        }
        try execute(git_signature_now(&signature, name, email))
        
        var parentCommit: OpaquePointer?
        var parentCount: Int = 0
        if git_repository_head_unborn(repository) == 0 {
            var headOid = git_oid()
            git_reference_name_to_id(&headOid, repository, "HEAD")
            git_commit_lookup(&parentCommit, repository, &headOid)
            parentCount = 1
        }
        
        var commitOid = git_oid()
        
        // Create the commit
        try execute(git_commit_create(
            &commitOid,              // Commit OID
            repository,              // Repository
            "HEAD",                  // Reference name
            signature,               // Author
            signature,               // Committer
            nil,                     // Message encoding
            message,                 // Commit message
            tree,                    // Tree object
            parentCount,             // Parent count
            &parentCommit            // Parent commits
        ))
        
        git_signature_free(signature)
        git_tree_free(tree)
        if parentCommit != nil {
            git_commit_free(parentCommit)
        }
    }
}
