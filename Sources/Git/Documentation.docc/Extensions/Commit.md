# ``Commit``

A Git commit representing a point in repository history.

## Overview

The `Commit` struct represents a single commit in a Git repository's history. It contains all the essential information about a commit including its unique identifier, message, author, committer, and parent relationships.

### Properties

Each commit provides access to:

- **Unique identifier**: A SHA-1 hash that uniquely identifies the commit
- **Commit message**: The descriptive message associated with the commit
- **Author information**: Details about who authored the changes
- **Committer information**: Details about who committed the changes (may differ from author)
- **Parent commits**: References to parent commits for tracking history

### Working with Commits

Commits are typically retrieved through repository operations:

```swift
// Get all commits in the repository
let commits = try await repository.log()

// Access commit information
for commit in commits {
    print("Commit ID: \(commit.id)")
    print("Message: \(commit.message)")
    print("Author: \(commit.author.name) <\(commit.author.email)>")
    print("Date: \(commit.author.date)")
    
    if !commit.parentIds.isEmpty {
        print("Parents: \(commit.parentIds.joined(separator: ", "))")
    }
}
```

### Getting the Current Commit

To get the current HEAD commit:

```swift
if let headCommit = try await repository.head() {
    print("Current commit: \(headCommit.message)")
    print("By: \(headCommit.author.name)")
}
```

## Identifiable Conformance

`Commit` conforms to `Identifiable`, making it easy to use with SwiftUI and other frameworks that require unique identification:

```swift
// Use in SwiftUI List
List(commits) { commit in
    VStack(alignment: .leading) {
        Text(commit.message)
            .font(.headline)
        Text("by \(commit.author.name)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
```