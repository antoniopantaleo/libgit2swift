//
//  RepositoryTests.swift
//  
//
//  Created by Antonio on 12/06/24.
//

import XCTest
import Libgit2Swift

final class RepositoryTests: XCTestCase {
    
    private let testDirectory = FileManager.default.temporaryDirectory.appending(path: "RepositoryTests")
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        Libgit2Swift.bootstrap()
        try? FileManager.default.removeItem(atPath: testDirectory.path())
        try FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: false)
    }
    
    override func tearDownWithError() throws {
        try FileManager.default.removeItem(atPath: testDirectory.path())
        Libgit2Swift.shutdown()
        try super.tearDownWithError()
    }
    
    func test_canNotCreateRepositoryFromNonGitDirectory() async throws {
        let directory = testDirectory.appending(path: "fake-directory-with-no-git-inside")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        do {
            _ = try await Repository(path: directory)
            XCTFail("Should have thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func test_canCreateRepositoryFromGitDirectory() async throws {
        let directory = testDirectory.appending(path: "fake-directory-with-git-inside")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        try git("init", directory: directory)
        let repository = try await Repository(path: directory)
        XCTAssertNotNil(repository)
    }
    
    func test_canCloneWithRealRemoteURL() async throws {
        let directory = testDirectory.appending(path: "antoniopantaleo-cloned")
        let url = URL(string: "https://github.com/antoniopantaleo/antoniopantaleo.git")!
        let repository = try await Repository(clone: url, path: directory)
        XCTAssertNotNil(repository)
    }
    
    // MARK: - Helpers
    
    @discardableResult
    private func git(_ command: String, directory: URL) throws -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "-C", directory.path(), command]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        try process.run()
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        return output?.isEmpty == false ? output : nil
    }
}
