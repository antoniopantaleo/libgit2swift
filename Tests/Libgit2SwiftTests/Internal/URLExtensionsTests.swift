//
//  URLExtensionsTests.swift
//  
//
//  Created by Antonio on 19/07/24.
//

import XCTest
@testable import Libgit2Swift

final class URLExtensionsTests: XCTestCase {
    
    func test_pathRelative_toParentDirectory() {
        let baseURL = URL(string: "/var/lib")!
        let sut = URL(string: "/var/lib/myFile.txt")!
        XCTAssertEqual(sut.path(relativeTo: baseURL)?.path(percentEncoded: false), "myFile.txt")
    }
    
    func test_pathRelative_toParentDirectory_withAdditionalDirectories() {
        let baseURL = URL(string: "/var/lib")!
        let sut = URL(string: "/var/lib/xcode/15.1/myFile.txt")!
        XCTAssertEqual(sut.path(relativeTo: baseURL)?.path(percentEncoded: false), "xcode/15.1/myFile.txt")
    }
    
    func test_pathRelative_toParentDirectory_withRepeatedOriginalDirectory() {
        let baseURL = URL(string: "/var/lib")!
        let sut = URL(string: "/var/lib/xcode/var/lib/myFile.txt")!
        XCTAssertEqual(sut.path(relativeTo: baseURL)?.path(percentEncoded: false), "xcode/var/lib/myFile.txt")
    }
    
    func test_pathRelative_toParentDirectory_differentDirectories() {
        let baseURL = URL(string: "/var/lib")!
        let sut = URL(string: "/xcode/myFile.txt")!
        XCTAssertNil(sut.path(relativeTo: baseURL))
    }
}
