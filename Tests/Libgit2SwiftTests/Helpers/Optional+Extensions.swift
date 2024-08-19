//
//  Optional+Extensions.swift
//
//
//  Created by Antonio on 19/08/24.
//

import Foundation
import XCTest

extension Optional {
    var xctUnwrapped: Wrapped {
        get throws {
            try XCTUnwrap(self)
        }
    }
}
