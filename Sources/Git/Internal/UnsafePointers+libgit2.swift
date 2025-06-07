//
//  UnsafePointers+libgit2.swift
//  Libgit2Swift
//
//  Created by Antonio on 07/06/25.
//

import Foundation
import libgit2

fileprivate typealias CommitIdRawBinary = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

extension UnsafePointer where Pointee == git_oid {
    var hash: String {
        func commitIdRawBinaryToData(raw: CommitIdRawBinary) -> Data {
            Data([
                raw.0,
                raw.1,
                raw.2,
                raw.3,
                raw.4,
                raw.5,
                raw.6,
                raw.7,
                raw.8,
                raw.9,
                raw.10,
                raw.11,
                raw.12,
                raw.13,
                raw.14,
                raw.15,
                raw.16,
                raw.17,
                raw.18,
                raw.19
            ])
        }
        let data = commitIdRawBinaryToData(raw: pointee.id)
        return data.map { String(format: "%02x", $0) }.joined()
    }
}

extension UnsafePointer where Pointee == git_signature {
    var signature: Signature {
        let name = String(cString: pointee.name)
        let email = String(cString: pointee.email)
        let timestamp = pointee.when.time
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return Signature(name: name, email: email, date: date)
    }
}

