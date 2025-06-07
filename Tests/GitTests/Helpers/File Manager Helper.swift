//
//  File Manager Helper.swift
//  
//
//  Created by Antonio on 19/08/24.
//

import Foundation

extension URL {
    func gitInit() throws -> URL {
        try git("init", directory: self)
        return self
    }
    
    func commit(message: String) throws -> URL {
        try git("commit", "-m", message, "--allow-empty", "--no-gpg-sign", directory: self)
        return self
    }
    
    func createFile(named name: String, content: Data) throws -> URL {
        let filePath = self.appending(path: name)
        FileManager.default.createFile(
            atPath: filePath.path(percentEncoded: false),
            contents: content
        )
        return filePath
    }
    
    func withGitUserName(_ name: String) throws -> URL {
        try git("config", "--local", "user.name", name, directory: self)
        return self
    }
    
    func withGitUserEmail(_ email: String) throws -> URL {
        try git("config", "--local", "user.email", email, directory: self)
        return self
    }
    
    @discardableResult
    func createDirectory(named name: String) throws -> URL {
        try FileManager.default.createDirectory(at: self.appending(path: name), withIntermediateDirectories: false)
        return self
    }
}
