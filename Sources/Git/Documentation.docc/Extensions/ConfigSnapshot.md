# ``ConfigSnapshot``

A snapshot of Git repository configuration.

## Overview

The `ConfigSnapshot` struct provides access to Git configuration values at a specific point in time. It captures the configuration state when created, ensuring consistent reads even if the underlying configuration changes.

This is particularly useful for operations that need to read multiple configuration values atomically, such as creating commits that require both user name and email.

### Key Features

- **Snapshot semantics**: Configuration values are captured at creation time
- **Memory management**: Uses `~Copyable` to ensure proper cleanup of underlying libgit2 resources  
- **Common properties**: Provides convenient access to frequently used configuration values

### Usage

Configuration snapshots are typically created internally by repository operations, but you can observe their usage:

```swift
// ConfigSnapshot is used internally when creating commits
try repository.commit(message: "My commit message")

// The commit operation uses ConfigSnapshot to read:
// - user.name
// - user.email
```

### Available Configuration

Currently, `ConfigSnapshot` provides access to:

- **User name** (`user.name`): The name used for commit signatures
- **User email** (`user.email`): The email used for commit signatures

These values are essential for creating valid Git commits and are automatically used by repository operations.

### Error Handling

If required configuration values (like user name or email) are not set, repository operations that depend on them will fail with descriptive error messages:

```swift
do {
    try repository.commit(message: "Test commit")
} catch let error as Repository.Error {
    // May fail if user.name or user.email is not configured
    print("Configuration error: \(error.localizedDescription)")
}
```

To configure Git user information, use the `git config` command:

```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```
