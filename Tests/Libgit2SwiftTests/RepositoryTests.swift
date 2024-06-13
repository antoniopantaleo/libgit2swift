//
//  RepositoryTests.swift
//  
//
//  Created by Antonio on 12/06/24.
//

import XCTest
import Libgit2Swift

final class RepositoryTests: XCTestCase {
    
    func test_canNotCreateRepositoryFromNonGitDirectory() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: "fake-directory-with-no-git-inside")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        let repository = Repository(path: directory.path())
        XCTAssertNil(repository)
        addTeardownBlock {
            try FileManager.default.removeItem(atPath: directory.path())
        }
    }
    
    func test_canCreateRepositoryFromGitDirectory() throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: "fake-directory-with-git-inside")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        try git("init", directory: directory)
        let repository = Repository(path: directory.path())
        XCTAssertNotNil(repository)
        addTeardownBlock {
            try FileManager.default.removeItem(atPath: directory.path())
        }
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
