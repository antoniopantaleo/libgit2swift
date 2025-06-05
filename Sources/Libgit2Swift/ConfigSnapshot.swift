//
//  ConfigSnapshot.swift
//
//
//  Created by Antonio on 20/08/24.
//

import Foundation
import libgit2

public struct ConfigSnapshot: ~Copyable {
    
    private var config: OpaquePointer!
    
    public init(repository: OpaquePointer) {
        git_repository_config_snapshot(&config, repository)
    }
    
    deinit {
        git_config_free(config)
    }
    
    public var userName: String? {
        getStringValue(forKey: "user.name")
    }
    
    public var userEmail: String? {
        getStringValue(forKey: "user.email")
    }
    
    private func getStringValue(forKey key: String) -> String? {
        var value: UnsafePointer<Int8>?
        git_config_get_string(&value, config, key)
        guard let value else { return nil }
        return String(cString: value)
    }
    
}
