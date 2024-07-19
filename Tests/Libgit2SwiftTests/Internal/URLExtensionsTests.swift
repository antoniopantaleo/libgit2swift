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
        let url1 = URL(string: "/var/lib")!
        let url2 = URL(string: "/var/lib/xcode/myFile.txt")!
        XCTAssertEqual(url2.path(relativeTo: url1)?.path(percentEncoded: false), "xcode/myFile.txt")
    }
}
