//
//  Libgit2Swift.swift
//
//
//  Created by Antonio Pantaleo on 13/06/24.
//

import Foundation
import Libgit2Package

public enum Libgit2Swift {
    public static func bootstrap() {
        git_libgit2_init()
    }
    
    public static func shutdown() {
        git_libgit2_shutdown()
    }
}
