//
//  RepositoryTests.swift
//  
//
//  Created by Antonio on 12/06/24.
//

import XCTest
import Libgit2Swift

final class RepositoryTests: XCTestCase {
    
    //MARK: Setup
    
    private let testDirectory = FileManager.default.temporaryDirectory.appending(path: "RepositoryTests")
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try? FileManager.default.removeItem(atPath: testDirectory.path())
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: false)
    }
    
    override func tearDownWithError() throws {
        try FileManager.default.removeItem(atPath: testDirectory.path())
        try super.tearDownWithError()
    }
    
    //MARK: Tests
    
    func test_canNotCreateRepositoryFromNonGitDirectory() async throws {
        // Given
        let directory = try directory(named: "fake-directory-with-no-git-inside")
        // Then
        try await XCTAssertThrowsError(
            try await Repository(path: directory),
            "Cannot create a repository from a non-git directory"
        )
    }
    
    func test_canCreateRepositoryFromGitDirectory() async throws {
        // Given
        let directory = try gitDirectory(named: "fake-directory-with-git-inside")
        // When
        let repository = try await Repository(path: directory)
        // Then
        XCTAssertNotNil(repository)
    }
    
    func test_canCloneWithRealRemoteURL() async throws {
        // Given
        let directory = testDirectory.appending(path: "antoniopantaleo-cloned")
        let gitRepoUrl = try URL(string: "https://github.com/antoniopantaleo/antoniopantaleo.git").xctUnwrapped
        // When
        let repository = try await Repository(clone: gitRepoUrl, path: directory)
        // Then
        XCTAssertNotNil(repository)
    }
    
    func test_canNotCloneWithFakeRemoteURL() async throws {
        // Given
        let directory = testDirectory.appending(path: "repo")
        let url = try URL(string: "https://a-repository-that-doesn't-exist").xctUnwrapped
        // Then
        try await XCTAssertThrowsError(
            try await Repository(clone: url, path: directory),
            "Cannot clone a non existing git repo"
        )
    }
    
    func test_gitLog_getAllCommitMessages() async throws {
        // Given
        let directory = try gitDirectory(named: "fake-directory-with-commits-inside")
            .commit(message: "First commit")
            .commit(message: "Second commit")
        let repository = try await Repository(path: directory)
        // When
        let log = try await repository.log()
        // Then
        XCTAssertEqual(
            log.map(\.message).map { $0.trimmingCharacters(in: .newlines)},
            ["First commit", "Second commit"]
        )
    }
    
    func test_canAddAFileToTheIndex() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
        let filePath = try directory.createFile(
            named: "file1.txt",
            content: try "Hello world!".data(using: .utf8).xctUnwrapped
        )
        let repository = try await Repository(path: directory)
        // When
        try await repository.add(filePath)
        // Then
        let indexStatus = try git("status", "-s", directory: directory)
        XCTAssertEqual(indexStatus, "A  file1.txt")
    }
    
    func test_canAddMultipleFilesToTheIndex() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
        let file1Path = try directory.createFile(
            named: "file1.txt",
            content: try "Hello world!".data(using: .utf8).xctUnwrapped
        )
        try directory.createDirectory(named: "folder")
        
        let file2Path = try directory.createFile(
            named: "folder/file2.txt",
            content: try "Hello world again!".data(using: .utf8).xctUnwrapped
        )
        let repository = try await Repository(path: directory)
        // When
        try await repository.add(file1Path)
        try await repository.add(file2Path)
        // Then
        let indexStatus = try git("status", "-s", directory: directory)!.components(separatedBy: .newlines)
        XCTAssertEqual(indexStatus[0], "A  file1.txt")
        XCTAssertEqual(indexStatus[1], "A  folder/file2.txt")
    }
    
    func test_commit_failsIfIndexIsEmpty() async throws {
        // Given
        let directory = try gitDirectory(named: "empty-git-repo")
        let repository = try await Repository(path: directory)
        // Then
        try await XCTAssertThrowsError(
            try await repository.commit(message: "commit message"),
            "Cannot commit if the index is empty"
        )
    }
    
    func test_commitsSuccesfullyWhenThereAreEntriesInIndex() async throws {
        // Given
        let directory = try gitDirectory(named: "git-directory")
            .withGitUserName("John Doe")
            .withGitUserEmail("john@doe.com")
        let file1Path = try directory.createFile(
            named: "file1.txt",
            content: try "Hello world!".data(using: .utf8).xctUnwrapped)
        try directory.createDirectory(named: "folder")

        let file2Path = try directory.createFile(
            named: "folder/file2.txt",
            content: try "Hello world again!".data(using: .utf8).xctUnwrapped)
        
        let repository = try await Repository(path: directory)
        
        try await repository.add(file1Path)
        try await repository.add(file2Path)
        // When
        try await repository.commit(message: "this is a commit")
        // Then
        let logs = try (try git("log", "--format=%an,%ae,%s", directory: directory)?.components(separatedBy: .newlines)).xctUnwrapped
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
        file: StaticString = #file,
        line: UInt = #line
    ) {
        zip(logs, data).forEach { log, data in
            let components = formatConverter(log)
            let authorName = components[0]
            let authorEmail = components[1]
            let commitMessage = components[2]
            XCTAssertEqual(authorName, data.authorName, file: file, line: line)
            XCTAssertEqual(authorEmail, data.authorEmail, file: file, line: line)
            XCTAssertEqual(commitMessage, data.commitMessage, file: file, line: line)
        }
    }
}
