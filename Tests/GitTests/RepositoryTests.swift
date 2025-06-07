//
//  RepositoryTests.swift
//  
//
//  Created by Antonio on 12/06/24.
//

import Foundation
import Testing
import Git

@Suite("Repository", .serialized)
struct RepositoryTests: ~Copyable {
    
    private let testDirectory = FileManager.default.temporaryDirectory.appending(path: "RepositoryTests")
    
    //MARK: Setup
    
    init() throws {
        try? FileManager.default.removeItem(atPath: testDirectory.path())
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: false)
    }
    
    deinit {
        try? FileManager.default.removeItem(atPath: testDirectory.path())
    }
    
    //MARK: Tests
    
    @Test("init from non-git directory")
    func nonGitDirectory() async throws {
        // Given
        let directory = try directory(named: "fake-directory-with-no-git-inside")
        // Then
        await #expect(throws: Repository.Error.self, "Cannot create a repository from a non-git directory") {
            try await Repository(path: directory)
        }
    }
    
    @Test("init from git directory")
    func gitDirectory() async throws {
        // Given
        let directory = try gitDirectory(named: "fake-directory-with-git-inside")
        // Then
        _ = try await Repository(path: directory)
    }
    
    @Test("clone existing remote")
    func realRemoteURL() async throws {
        // Given
        let directory = testDirectory.appending(path: "antoniopantaleo-cloned")
        let gitRepoUrl = try #require(URL(string: "https://github.com/antoniopantaleo/antoniopantaleo.git"))
        // Then
        _ = try await Repository(clone: gitRepoUrl, path: directory)
    }
    
    @Test("clone non existing remote")
    func nonExistingRemoteURL() async throws {
        // Given
        let directory = testDirectory.appending(path: "repo")
        let url = try #require(URL(string: "https://a-repository-that-doesn't-exist"))
        // Then
        await #expect(throws: Repository.Error.self, "Cannot clone a non existing git repo") {
            try await Repository(clone: url, path: directory)
        }
    }
    
    @Test("log")
    func logMessages() async throws {
        // Given
        let directory = try gitDirectory(named: "fake-directory-with-commits-inside")
            .commit(message: "First commit")
            .commit(message: "Second commit")
        let repository = try await Repository(path: directory)
        // When
        let log = try await repository.log()
        // Then
        #expect(
            log.map(\.message) ==
            ["Second commit", "First commit"]
        )
    }
    
    @Test("add single file to index")
    func addSingleFile() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
        let filePath = try directory.createFile(
            named: "file1.txt",
            content: try #require("Hello world!".data(using: .utf8))
        )
        let repository = try await Repository(path: directory)
        // When
        try await repository.add(filePath)
        // Then
        let indexStatus = try git("status", "-s", directory: directory)
        #expect(indexStatus == "A  file1.txt")
    }
    
    @Test("add non existing file to index")
    func addNonExistingFile() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
        let filePath = directory.appending(component: "non-existing-file")
        let repository = try await Repository(path: directory)
        // When
        await #expect(throws: Repository.Error.self) {
            try await repository.add(filePath)
        }
    }
    
    @Test("add multiple files to index")
    func addMultipleFiles() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
        let file1Path = try directory.createFile(
            named: "file1.txt",
            content: try #require("Hello world!".data(using: .utf8))
        )
        try directory.createDirectory(named: "folder")
        
        let file2Path = try directory.createFile(
            named: "folder/file2.txt",
            content: try #require("Hello world again!".data(using: .utf8))
        )
        let repository = try await Repository(path: directory)
        // When
        try await repository.add(file1Path)
        try await repository.add(file2Path)
        // Then
        let indexStatus = try git("status", "-s", directory: directory)!.components(separatedBy: .newlines)
        #expect(indexStatus[0] == "A  file1.txt")
        #expect(indexStatus[1] == "A  folder/file2.txt")
    }
    
    @Test("commit empty index")
    func commitEmptyIndex() async throws {
        // Given
        let directory = try gitDirectory(named: "empty-git-repo")
        let repository = try await Repository(path: directory)
        // Then
        await #expect(throws: Repository.Error.self, "Cannot commit if the index is empty") {
            try await repository.commit(message: "commit message")
        }
    }
    
    @Test("commit")
    func commit() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
            .withGitUserName("John Doe")
            .withGitUserEmail("john@doe.com")
        let file1Path = try directory.createFile(
            named: "file1.txt",
            content: try #require("Hello world!".data(using: .utf8)))
        try directory.createDirectory(named: "folder")

        let file2Path = try directory.createFile(
            named: "folder/file2.txt",
            content: try #require("Hello world again!".data(using: .utf8)))
        
        let repository = try await Repository(path: directory)
        
        try await repository.add(file1Path)
        try await repository.add(file2Path)
        // When
        try await repository.commit(message: "this is a commit")
        // Then
        let logs = try #require((try git("log", "--format=%an,%ae,%s", directory: directory)?.components(separatedBy: .newlines)))
        assertLogs(logs, equalTo: [("John Doe", "john@doe.com", "this is a commit")])
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
    
    private func assertLogs(
        _ logs: [String],
        equalTo data: [(authorName: String, authorEmail: String, commitMessage: String)],
        formatConverter: (String) -> [String] = { result in result.components(separatedBy: ",") },
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        zip(logs, data).forEach { log, data in
            let components = formatConverter(log)
            let authorName = components[0]
            let authorEmail = components[1]
            let commitMessage = components[2]
            #expect(authorName == data.authorName)
            #expect(authorEmail == data.authorEmail)
            #expect(commitMessage == data.commitMessage)
        }
    }
}
