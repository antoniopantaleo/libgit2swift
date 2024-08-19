//
//  URLExtensionsTests.swift
//  
//
//  Created by Antonio on 19/07/24.
//

import XCTest
@testable import Libgit2Swift

final class URLExtensionsTests: XCTestCase {
    
    func test_pathRelative_toParentDirectory() throws {
        let baseURL = try URL(string: "/var/lib").xctUnwrapped
        let sut = try URL(string: "/var/lib/myFile.txt").xctUnwrapped
        XCTAssertEqual(sut.path(relativeTo: baseURL)?.path(percentEncoded: false), "myFile.txt")
    }
    
    func test_pathRelative_toParentDirectory_withAdditionalDirectories() throws {
        let baseURL = try URL(string: "/var/lib").xctUnwrapped
        let sut = try URL(string: "/var/lib/xcode/15.1/myFile.txt").xctUnwrapped
        XCTAssertEqual(sut.path(relativeTo: baseURL)?.path(percentEncoded: false), "xcode/15.1/myFile.txt")
    }
    
    func test_pathRelative_toParentDirectory_withRepeatedOriginalDirectory() throws {
        let baseURL = try URL(string: "/var/lib").xctUnwrapped
        let sut = try URL(string: "/var/lib/xcode/var/lib/myFile.txt").xctUnwrapped
        XCTAssertEqual(sut.path(relativeTo: baseURL)?.path(percentEncoded: false), "xcode/var/lib/myFile.txt")
    }
    
    func test_pathRelative_toParentDirectory_differentDirectories() throws {
        let baseURL = try URL(string: "/var/lib").xctUnwrapped
        let sut = try URL(string: "/xcode/myFile.txt").xctUnwrapped
        XCTAssertNil(sut.path(relativeTo: baseURL))
    }
}
