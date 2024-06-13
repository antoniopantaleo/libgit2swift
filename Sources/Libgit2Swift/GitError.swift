//
//  GitError.swift
//  
//
//  Created by Antonio Pantaleo on 13/06/24.
//

import Foundation

enum GitError: Error {
    case clone(message: String)
}
