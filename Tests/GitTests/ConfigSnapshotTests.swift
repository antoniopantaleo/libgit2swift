//
//  ConfigSnapshotTests.swift
//  
//
//  Created by Antonio on 08/06/25.
//

import Foundation
import Testing
import Git

@Suite("ConfigSnapshot", .serialized)
struct ConfigSnapshotTests: ~Copyable {
    
    private let testDirectory = FileManager.default.temporaryDirectory.appending(path: "ConfigSnapshotTests")
    
    //MARK: Setup
    
    init() throws {
        try? FileManager.default.removeItem(atPath: testDirectory.path())
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: false)
    }
    
    deinit {
        try? FileManager.default.removeItem(atPath: testDirectory.path())
    }
    
    @Test("config snapshot with user configuration")
    func configSnapshotWithUserConfig() async throws {
        // Given
        let directory = try gitDirectory(named: "config-test")
            .withGitUserName("Test User")
            .withGitUserEmail("test@example.com")
        let repository = try await Repository(path: directory)
        
        // Create a file and add it to trigger config snapshot usage internally
        let filePath = try directory.createFile(
            named: "test.txt",
            content: try #require("test content".data(using: .utf8))
        )
        try await repository.add(filePath)
        
        // When/Then - This should succeed, indicating config snapshot worked
        try await repository.commit(message: "Test commit")
        
        let commits = try await repository.log()
        let commit = try #require(commits.first)
        #expect(commit.author.name == "Test User")
        #expect(commit.author.email == "test@example.com")
    }
    
    
    // MARK: - Helpers
    
    private func directory(named name: String) throws -> URL {
        let directory = testDirectory.appending(path: name)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        return directory
    }
    
    private func gitDirectory(named name: String) throws -> URL {
        try directory(named: name).gitInit()
    }
}

