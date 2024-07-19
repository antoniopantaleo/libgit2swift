//
//  URL+Extensions.swift
//
//
//  Created by Antonio on 19/07/24.
//

import Foundation

extension URL {
    func path(relativeTo url: URL) -> URL? {
        guard let baseRegex = try? Regex(url.path() + "/") else { return nil }
        let path = self.path()
        guard let match = path.firstMatch(of: baseRegex) else { return nil }
        let range = match.range
        return URL(string: path.replacingCharacters(in: range, with: ""))
    }
}

