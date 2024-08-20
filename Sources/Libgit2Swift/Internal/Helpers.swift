//
//  Helpers.swift
//  
//
//  Created by Antonio on 20/08/24.
//

import Foundation
import libgit2

func execute(_ block: @autoclosure () -> Int32) throws {
    let exitCode = block()
    if exitCode != GIT_OK.rawValue {
        var errorMessage = "An error occurred"
        if let error = git_error_last().pointee.message {
            errorMessage = String(cString: error)
        }
        throw GitError.add(message: errorMessage)
    }
}
