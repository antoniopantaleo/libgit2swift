//
//  Logger+Extensions.swift
//  
//
//  Created by Antonio Pantaleo on 13/06/24.
//

import Foundation
import os

extension Logger {
    init(category: String) {
        self.init(subsystem: "com.antoniopantaleo.Libgit2Swift", category: category)
    }
}
