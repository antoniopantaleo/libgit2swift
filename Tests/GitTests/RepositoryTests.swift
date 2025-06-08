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
    
    @Test("head from repository with commits")
    func headWithCommits() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory-with-commits")
            .withGitUserName("Jane Doe")
            .withGitUserEmail("jane@doe.com")
        let filePath = try directory.createFile(
            named: "readme.txt",
            content: try #require("Initial content".data(using: .utf8))
        )
        let repository = try await Repository(path: directory)
        
        try await repository.add(filePath)
        try await repository.commit(message: "Initial commit")
        
        // Add another commit
        _ = try directory.createFile(
            named: "second.txt",
            content: try #require("Second file".data(using: .utf8))
        )
        try await repository.add(directory.appending(path: "second.txt"))
        try await repository.commit(message: "Second commit")
        
        // When
        let head = try await repository.head()
        
        // Then
        let headCommit = try #require(head)
        #expect(headCommit.message == "Second commit")
        #expect(headCommit.author.name == "Jane Doe")
        #expect(headCommit.author.email == "jane@doe.com")
        #expect(headCommit.committer.name == "Jane Doe")
        #expect(headCommit.committer.email == "jane@doe.com")
        #expect(!headCommit.id.isEmpty)
    }
    
    @Test("head from repository with single commit")
    func headWithSingleCommit() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory-single-commit")
            .withGitUserName("Alice Smith")
            .withGitUserEmail("alice@smith.com")
        let filePath = try directory.createFile(
            named: "file.txt",
            content: try #require("Content".data(using: .utf8))
        )
        let repository = try await Repository(path: directory)
        
        try await repository.add(filePath)
        try await repository.commit(message: "Only commit")
        
        // When
        let head = try await repository.head()
        
        // Then
        let headCommit = try #require(head)
        #expect(headCommit.message == "Only commit")
        #expect(headCommit.author.name == "Alice Smith")
        #expect(headCommit.author.email == "alice@smith.com")
        #expect(headCommit.parentIds.isEmpty) // First commit has no parents
    }
    
    @Test("head from empty repository")
    func headFromEmptyRepository() async throws {
        // Given
        let directory = try gitDirectory(named: "empty-git-repo")
        let repository = try await Repository(path: directory)
        
        // When/Then
        await #expect(throws: Repository.Error.self, "Empty repository should not have HEAD") {
            _ = try await repository.head()
        }
    }
    
    
    @Test("add file outside repository")
    func addFileOutsideRepository() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
        let outsideFile = try testDirectory.createFile(
            named: "outside.txt",
            content: try #require("Outside content".data(using: .utf8))
        )
        let repository = try await Repository(path: directory)
        
        // When/Then
        await #expect(throws: Repository.Error.self, "Should fail for files outside repository") {
            try await repository.add(outsideFile)
        }
    }
    
    @Test("log from repository with no commits")
    func logFromEmptyRepository() async throws {
        // Given
        let directory = try gitDirectory(named: "empty-git-repo")
        let repository = try await Repository(path: directory)
        
        // When
        let commits = try await repository.log()
        
        // Then
        #expect(commits.isEmpty)
    }
    
    @Test("repository error localized description")
    func repositoryErrorDescription() {
        // Given
        let error = Repository.Error(message: "Test error message")
        
        // Then
        #expect(error.errorDescription == "Test error message")
    }
    
    @Test("commit with multiline message")
    func commitWithMultilineMessage() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
            .withGitUserName("John Doe")
            .withGitUserEmail("john@doe.com")
        let filePath = try directory.createFile(
            named: "file.txt",
            content: try #require("Content".data(using: .utf8))
        )
        let repository = try await Repository(path: directory)
        
        try await repository.add(filePath)
        
        let multilineMessage = """
        This is a multiline commit message
        
        With additional details
        And even more information
        """
        
        // When
        try await repository.commit(message: multilineMessage)
        
        // Then
        let commits = try await repository.log()
        #expect(commits.first?.message == multilineMessage)
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
