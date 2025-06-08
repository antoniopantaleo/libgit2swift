//
//  CommitTests.swift
//  
//
//  Created by Antonio on 08/06/25.
//

import Foundation
import Testing
@testable import Git

@Suite("Commit")
struct CommitTests {
    
    @Test("commit identifiable conformance")
    func identifiableConformance() {
        // Given
        let commit1 = Commit(
            id: "abc123",
            message: "First commit",
            author: Signature(name: "John", email: "john@example.com", date: Date()),
            committer: Signature(name: "John", email: "john@example.com", date: Date())
        )
        let commit2 = Commit(
            id: "def456",
            message: "Second commit", 
            author: Signature(name: "Jane", email: "jane@example.com", date: Date()),
            committer: Signature(name: "Jane", email: "jane@example.com", date: Date())
        )
        
        // Then
        #expect(commit1.id == "abc123")
        #expect(commit2.id == "def456")
        #expect(commit1.id != commit2.id)
    }
    
    @Test("commit message trimming")
    func messageTrimming() {
        // Given
        let commitWithNewlines = Commit(
            id: "abc123",
            message: "Commit message\n\n",
            author: Signature(name: "John", email: "john@example.com", date: Date()),
            committer: Signature(name: "John", email: "john@example.com", date: Date())
        )
        
        // Then
        #expect(commitWithNewlines.message == "Commit message")
    }
    
    @Test("commit with parent ids")
    func commitWithParents() {
        // Given
        let commitWithParents = Commit(
            id: "abc123",
            message: "Merge commit",
            author: Signature(name: "John", email: "john@example.com", date: Date()),
            committer: Signature(name: "John", email: "john@example.com", date: Date()),
            parentIds: ["parent1", "parent2"]
        )
        
        // Then
        #expect(commitWithParents.parentIds.count == 2)
        #expect(commitWithParents.parentIds.contains("parent1"))
        #expect(commitWithParents.parentIds.contains("parent2"))
    }
    
    @Test("commit without parent ids")
    func initialCommit() {
        // Given
        let initialCommit = Commit(
            id: "abc123",
            message: "Initial commit",
            author: Signature(name: "John", email: "john@example.com", date: Date()),
            committer: Signature(name: "John", email: "john@example.com", date: Date())
        )
        
        // Then
        #expect(initialCommit.parentIds.isEmpty)
    }
    
    @Test("author and committer can be different")
    func differentAuthorAndCommitter() {
        // Given
        let authorDate = Date()
        let committerDate = Date().addingTimeInterval(3600) // 1 hour later
        
        let commit = Commit(
            id: "abc123",
            message: "Applied patch",
            author: Signature(name: "Original Author", email: "author@example.com", date: authorDate),
            committer: Signature(name: "Maintainer", email: "maintainer@example.com", date: committerDate)
        )
        
        // Then
        #expect(commit.author.name == "Original Author")
        #expect(commit.author.email == "author@example.com")
        #expect(commit.committer.name == "Maintainer")
        #expect(commit.committer.email == "maintainer@example.com")
        #expect(commit.author.date == authorDate)
        #expect(commit.committer.date == committerDate)
    }
}
