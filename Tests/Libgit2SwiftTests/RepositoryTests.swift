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
        let lastDirectoryPath = "fake-directory-with-no-git-inside"
        let directory = FileManager.default.temporaryDirectory.appending(path: lastDirectoryPath)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
        let repository = Repository(path: directory.path())
        XCTAssertNil(repository)
        addTeardownBlock {
            try FileManager.default.removeItem(atPath: directory.path())
        }
    }
}
