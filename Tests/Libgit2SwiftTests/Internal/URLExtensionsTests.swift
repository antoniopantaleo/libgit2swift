//
//  URLExtensionsTests.swift
//  
//
//  Created by Antonio on 19/07/24.
//

import Foundation
import Testing
@testable import Libgit2Swift

@Suite("URLExtensions")
struct URLExtensionsTests {
    
    @Test("path relative to parent directory")
    func parentDirectory() throws {
        let baseURL = try #require(URL(string: "/var/lib"))
        let sut = try #require(URL(string: "/var/lib/myFile.txt"))
        #expect(sut.path(relativeTo: baseURL)?.path(percentEncoded: false) == "myFile.txt")
    }
    
    @Test("path relative to parent directory with single additional directory")
    func additionalDirectories() throws {
        let baseURL = try #require(URL(string: "/var/lib"))
        let sut = try #require(URL(string: "/var/lib/xcode/15.1/myFile.txt"))
        #expect(sut.path(relativeTo: baseURL)?.path(percentEncoded: false) == "xcode/15.1/myFile.txt")
    }
    
    @Test("path relative to parent directory with repeated original directory")
    func repeatedOriginalDirectory() throws {
        let baseURL = try #require(URL(string: "/var/lib"))
        let sut = try #require(URL(string: "/var/lib/xcode/var/lib/myFile.txt"))
        #expect(sut.path(relativeTo: baseURL)?.path(percentEncoded: false) == "xcode/var/lib/myFile.txt")
    }
    
    @Test("path relative to parent directory different directories")
    func differentDirectories() throws {
        let baseURL = try #require(URL(string: "/var/lib"))
        let sut = try #require(URL(string: "/xcode/myFile.txt"))
        #expect(sut.path(relativeTo: baseURL) == nil)
    }
}
