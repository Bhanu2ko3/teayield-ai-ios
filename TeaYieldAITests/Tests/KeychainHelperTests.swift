import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("iOS Keychain Security Hardware Layer Unit Tests")
struct KeychainHelperTests {

    private let keychain = KeychainHelper.shared
    private let testKey = "test.security.token.key"

    @Test("Saves and reads UTF-8 string token from iOS Keychain successfully")
    func testSaveAndReadString() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_field_officer_token"
        
        let saveResult = keychain.save(token, forKey: testKey)
        #expect(saveResult == true)

        let retrieved = keychain.readString(forKey: testKey)
        #expect(retrieved == token)

        // Cleanup
        _ = keychain.delete(forKey: testKey)
        #expect(keychain.readString(forKey: testKey) == nil)
    }

    @Test("Encodes and decodes Codable domain entities securely to Keychain")
    func testCodableObjectPersistence() {
        let userKey = "test.security.user.profile"
        let testProfile = UserProfile(
            id: UUID(),
            email: "manager@pedro.lk",
            fullName: "Bhanuka Bandara",
            role: .estateManager,
            employeeId: "MGR-082",
            estateId: UUID(),
            hasOnboardedEstate: true
        )

        let saveResult = keychain.saveObject(testProfile, forKey: userKey)
        #expect(saveResult == true)

        let loaded: UserProfile? = keychain.readObject(forKey: userKey)
        #expect(loaded != nil)
        #expect(loaded?.email == "manager@pedro.lk")
        #expect(loaded?.employeeId == "MGR-082")
        #expect(loaded?.role == .estateManager)

        // Cleanup
        _ = keychain.delete(forKey: userKey)
        let afterDelete: UserProfile? = keychain.readObject(forKey: userKey)
        #expect(afterDelete == nil)
    }

    @Test("Overwriting existing key replaces value idempotently")
    func testIdempotentOverwrite() {
        let key = "test.security.overwrite.key"
        _ = keychain.save("initial_value", forKey: key)
        #expect(keychain.readString(forKey: key) == "initial_value")

        _ = keychain.save("updated_value", forKey: key)
        #expect(keychain.readString(forKey: key) == "updated_value")

        // Cleanup
        _ = keychain.delete(forKey: key)
    }
}

#else
import XCTest

final class KeychainHelperTests: XCTestCase {
    private let keychain = KeychainHelper.shared
    private let testKey = "test.security.token.key"

    func testSaveAndReadString() {
        let token = "dummy_token_123"
        let saveResult = keychain.save(token, forKey: testKey)
        XCTAssertTrue(saveResult)

        let retrieved = keychain.readString(forKey: testKey)
        XCTAssertEqual(retrieved, token)

        _ = keychain.delete(forKey: testKey)
    }
}
#endif
