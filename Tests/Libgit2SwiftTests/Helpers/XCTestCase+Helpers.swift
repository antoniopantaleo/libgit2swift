//
//  XCTestCase+Helpers.swift
//
//
//  Created by Antonio on 20/08/24.
//

import Foundation
import XCTest

extension XCTestCase {
    func XCTAssertThrowsError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: any Error) -> Void = { _ in }
    ) async rethrows {
        let message = message()
        do {
            let _ = try await expression()
            XCTFail(
                message.isEmpty ? "Expression did not throw" : message,
                file: file,
                line: line
            )
        } catch { errorHandler(error) }
    }
}
