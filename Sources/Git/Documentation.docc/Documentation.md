# ``Git``

@Metadata {
    @PageColor(orange)
}

A Swift wrapper around libgit2 for Git repository operations.

Git provides a modern Swift interface to the powerful [libgit2](https://libgit2.org) library, enabling you to perform Git operations programmatically with type safety and async/await support.

## Overview

The Git library is designed to provide an intuitive and Swift-native way to interact with Git repositories. Built on top of the battle-tested libgit2 C library, it offers:

- **Type-safe API**: All operations are wrapped in Swift types with proper error handling
- **Async/await support**: Modern concurrency patterns for non-blocking repository operations  
- **Actor-based safety**: Repository operations are safely isolated using Swift actors
- **Comprehensive logging**: Built-in logging support using swift-log for debugging and monitoring

Whether you need to clone repositories, read commit history, or perform basic Git operations, this library provides the tools you need while maintaining the safety and expressiveness of Swift.

## Getting Started

```swift
import Git

// Open an existing repository
let repo = try await Repository(path: URL(fileURLWithPath: "/path/to/repo"))

// Clone a repository
let clonedRepo = try await Repository(
    clone: URL(string: "https://github.com/user/repo.git")!,
    path: URL(fileURLWithPath: "/path/to/clone")
)

// Get commit history
let commits = try await repo.log()

// Get HEAD commit
let head = try await repo.head()
```

## Topics

### Essentials

- ``Repository``
- ``Commit``
- ``Signature``

### Configuration

- ``ConfigSnapshot``
