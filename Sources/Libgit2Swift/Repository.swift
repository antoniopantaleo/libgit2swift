//
//  Repository.swift
//
//
//  Created by Antonio Pantaleo on 12/06/24.
//

import Foundation
import Libgit2Package

public actor Repository {
    
    private var repository: OpaquePointer?
    
    public init?(path: String) {
        git_libgit2_init()
        let exitCode = git_repository_open(&repository, path)
        if exitCode != 0 { return nil }
        git_libgit2_shutdown()
    }
}
