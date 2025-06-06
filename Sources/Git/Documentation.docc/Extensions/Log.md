# Working with Repository Logs

Learn how to retrieve and work with commit history using the Git library.

## Overview

The commit log represents the history of changes in a Git repository. The Git library provides convenient methods to access this history through the `Repository.log()` method, which returns an array of `Commit` objects in chronological order.

### Basic Log Retrieval

Retrieve the complete commit history:

```swift
let repository = try await Repository(path: repositoryURL)
let commits = try await repository.log()

print("Found \(commits.count) commits")
```

### Processing Commit History

Iterate through commits to access their information:

```swift
let commits = try await repository.log()

for commit in commits {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("Commit: \(commit.id)")
    print("Date: \(commit.author.date)")
    print("Author: \(commit.author.name) <\(commit.author.email)>")
    print("Message: \(commit.message)")
    
    if !commit.parentIds.isEmpty {
        print("Parents: \(commit.parentIds.joined(separator: ", "))")
    }
}
```

### Commit Ordering

Commits are returned in topological order, which means:
- Child commits appear before their parents
- The most recent commits appear first
- Merge commits are handled appropriately

This ordering is ideal for displaying commit history in user interfaces or processing commits in dependency order.

### Performance Considerations

- The `log()` method loads all commits into memory at once
- For repositories with extensive history, consider the memory implications
- The operation is performed asynchronously to avoid blocking the calling thread

### Getting Individual Commits

For getting just the latest commit, use the `head()` method instead:

```swift
if let latestCommit = try await repository.head() {
    print("Latest: \(latestCommit.message)")
}
```
