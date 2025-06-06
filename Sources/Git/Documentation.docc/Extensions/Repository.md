# ``Repository``

A Git repository actor that provides safe access to repository operations.

## Overview

The `Repository` actor represents a Git repository and provides thread-safe access to various Git operations. It wraps the libgit2 library functionality in a modern Swift API with proper error handling and async/await support.

All repository operations are performed asynchronously to avoid blocking the calling thread, making it suitable for use in both command-line tools and user-facing applications.

### Opening a Repository

You can open an existing Git repository by providing its path:

```swift
let repo = try await Repository(path: URL(fileURLWithPath: "/path/to/existing/repo"))
```

### Cloning a Repository

To clone a remote repository:

```swift
let repo = try await Repository(
    clone: URL(string: "https://github.com/user/repo.git")!,
    path: URL(fileURLWithPath: "/path/to/clone/destination")
)
```

### Working with Commits

Retrieve the commit history:

```swift
let commits = try await repo.log()
for commit in commits {
    print("Commit: \(commit.id)")
    print("Author: \(commit.author.name)")
    print("Message: \(commit.message)")
}
```

Get the HEAD commit:

```swift
let headCommit = try await repo.head()
```

### Making Changes

Add files to the index and create commits:

```swift
// Add a file to the index
try repo.add(URL(fileURLWithPath: "path/to/file.txt"))

// Create a commit
try repo.commit(message: "Add new feature")
```

## Error Handling

All repository operations can throw `Repository.Error` with descriptive error messages from the underlying libgit2 library. Always wrap repository operations in appropriate error handling:

```swift
do {
    let repo = try await Repository(path: repoPath)
    let commits = try await repo.log()
} catch let error as Repository.Error {
    print("Repository error: \(error.localizedDescription)")
} catch {
    print("Unexpected error: \(error)")
}
```
