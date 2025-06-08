//
//  SignatureTests.swift
//  
//
//  Created by Antonio on 08/06/25.
//

import Foundation
import Testing
@testable import Git

@Suite("Signature")
struct SignatureTests {
    
    @Test("signature creation")
    func signatureCreation() {
        // Given
        let date = Date()
        let signature = Signature(name: "John Doe", email: "john@example.com", date: date)
        
        // Then
        #expect(signature.name == "John Doe")
        #expect(signature.email == "john@example.com")
        #expect(signature.date == date)
    }
    
    @Test("signature sendable conformance")
    func sendableConformance() async {
        // Given
        let signature = Signature(name: "Jane Doe", email: "jane@example.com", date: Date())
        
        // When/Then - This should compile without warnings due to Sendable conformance
        let task = Task {
            return signature.name
        }
        
        let name = await task.value
        #expect(name == "Jane Doe")
    }
    
    @Test("signature with empty values")
    func emptyValues() {
        // Given
        let signature = Signature(name: "", email: "", date: Date())
        
        // Then
        #expect(signature.name.isEmpty)
        #expect(signature.email.isEmpty)
    }
    
    @Test("signature equality comparison")
    func equalityComparison() {
        // Given
        let date = Date()
        let signature1 = Signature(name: "John Doe", email: "john@example.com", date: date)
        let signature2 = Signature(name: "John Doe", email: "john@example.com", date: date)
        let signature3 = Signature(name: "Jane Doe", email: "jane@example.com", date: date)
        
        // Then
        #expect(signature1.name == signature2.name)
        #expect(signature1.email == signature2.email)
        #expect(signature1.date == signature2.date)
        #expect(signature1.name != signature3.name)
        #expect(signature1.email != signature3.email)
    }
}
