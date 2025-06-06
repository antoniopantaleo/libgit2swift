# ``Signature``

Author and committer information for Git commits.

## Overview

The `Signature` struct represents the identity of a person in Git, typically used for commit authors and committers. It encapsulates the name, email address, and timestamp information.

### Properties

A signature contains:

- **Name**: The person's name as configured in Git
- **Email**: The person's email address 
- **Date**: When the action (authoring or committing) occurred

### Usage

Signatures are automatically created by Git operations and are accessed through commit objects:

```swift
let commits = try await repository.log()

for commit in commits {
    let author = commit.author
    let committer = commit.committer
    
    print("Authored by: \(author.name) <\(author.email)>")
    print("Authored on: \(author.date)")
    
    // Author and committer may be different
    if author.name != committer.name || author.email != committer.email {
        print("Committed by: \(committer.name) <\(committer.email)>")
        print("Committed on: \(committer.date)")
    }
}
```

### Author vs Committer

Git distinguishes between the author and committer of a change:

- **Author**: The person who originally wrote the code
- **Committer**: The person who last applied the change

These are often the same person, but can differ in workflows involving patches, rebasing, or collaborative development where someone else applies another person's changes.

## Thread Safety

`Signature` conforms to `Sendable`, making it safe to use across concurrent contexts without additional synchronization.