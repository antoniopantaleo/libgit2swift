//
//  RepositoryTests.swift
//  
//
//  Created by Antonio on 12/06/24.
//

import os
import XCTest
import Libgit2Swift

final class RepositoryTests: XCTestCase {
    
    private let logger = Logger(subsystem: "com.antoniopantaleo.Libgit2SwiftTests", category: "RepositoryTests")
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
    
    func test_canNotCreateRepositoryFromNonGitDirectory() async throws {
        logger.info("Creating a fake directory with no git inside")
        let directory = try directory(named: "fake-directory-with-no-git-inside")
        logger.info("Creating directory at \(directory)")
        do {
            logger.info("Trying to create a repository from \(directory)")
            _ = try await Repository(path: directory)
            XCTFail("Should have thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_canCreateRepositoryFromGitDirectory() async throws {
        let directory = try gitDirectory(named: "fake-directory-with-git-inside")
        let repository = try await Repository(path: directory)
        XCTAssertNotNil(repository)
    }
    
    func test_canCloneWithRealRemoteURL() async throws {
        let directory = testDirectory.appending(path: "antoniopantaleo-cloned")
        let url = try URL(string: "https://github.com/antoniopantaleo/antoniopantaleo.git").xctUnwrapped
        let repository = try await Repository(clone: url, path: directory)
        XCTAssertNotNil(repository)
    }
    
    func test_canNotCloneWithFakeRemoteURL() async throws {
        let directory = testDirectory.appending(path: "repo")
        let url = try URL(string: "https://a-repository-that-doesn't-exist").xctUnwrapped
        do {
            _ = try await Repository(clone: url, path: directory)
            XCTFail("Should have thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_gitLog_getAllCommitMessages() async throws {
        let directory = try gitDirectory(named: "fake-directory-with-commits-inside")
            .commit(message: "First commit")
            .commit(message: "Second commit")
        let repository = try await Repository(path: directory)
        let log = try await repository.log()
        XCTAssertEqual(
            log.map(\.message).map { $0.trimmingCharacters(in: .newlines)},
            ["First commit", "Second commit"]
        )
    }
    
    func test_canAddAFileToTheIndex() async throws {
        let directory = try gitDirectory(named: "git-directory")
        let filePath = try directory.createFile(
            named: "file1.txt",
            content: try "Hello world!".data(using: .utf8).xctUnwrapped
        )
        logger.log("Created file at \(filePath.path(percentEncoded: false))")
        let repository = try await Repository(path: directory)
        try await repository.add(filePath)
        let indexStatus = try git("status", "-s", directory: directory)
        XCTAssertEqual(indexStatus, "A  file1.txt")
    }
    
    func test_canAddMultipleFilesToTheIndex() async throws {
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
        try await repository.add(file1Path)
        try await repository.add(file2Path)
        let indexStatus = try git("status", "-s", directory: directory)!.components(separatedBy: .newlines)
        XCTAssertEqual(indexStatus[0], "A  file1.txt")
        XCTAssertEqual(indexStatus[1], "A  folder/file2.txt")
    }
    
    func test_commit_failsIfIndexIsEmpty() async throws {
        let directory = try gitDirectory(named: "empty-git-repo")
        let repository = try await Repository(path: directory)
        do {
            try await repository.commit(message: "commit message")
            XCTFail("Expected to throw but it succeded")
        } catch {}
    }
    
    func test_commitsSuccesfullyWhenThereAreEntriesInIndex() async throws {
        let directory = try gitDirectory(named: "git-directory")
        
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
        
        do {
            try await repository.commit(message: "this is a commit")
            let logs = try (try git("log", "--format=%an,%ae,%s", directory: directory)?.components(separatedBy: .newlines)).xctUnwrapped
            assertLogs(logs, equalTo: [("authorName", "authorEmail", "this is a commit")])
        } catch {
            XCTFail("Expected to commit succesfully")
        }
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
        formatConverter: (String) -> [String] = { result in result.components(separatedBy: ",") }
    ) {
        zip(logs, data).forEach { log, data in
            let components = formatConverter(log)
            let authorName = components[0]
            let authorEmail = components[1]
            let commitMessage = components[2]
            XCTAssertEqual(authorName, data.authorName)
            XCTAssertEqual(authorEmail, data.authorEmail)
            XCTAssertEqual(commitMessage, data.commitMessage)
        }
    }
}
