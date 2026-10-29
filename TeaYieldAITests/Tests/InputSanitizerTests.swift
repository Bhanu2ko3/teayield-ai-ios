import Foundation
@testable import TeaYieldAI

#if canImport(Testing)
import Testing

@Suite("Input Sanitizer & Validation Constraint Unit Tests")
struct InputSanitizerTests {

    @Test("Filters phone numbers to strip out letters and invalid characters")
    func phoneNumberSanitization() {
        // Raw letters should be completely eliminated
        let inputWithLetters = "+94 77 ABC 123 4567"
        let sanitized = InputSanitizer.sanitizePhoneNumber(inputWithLetters)
        #expect(sanitized == "+94 77 123 4567")

        // Leading plus should be retained, subsequent plus removed
        let duplicatePlus = "+94+771234567"
        #expect(InputSanitizer.sanitizePhoneNumber(duplicatePlus) == "+94771234567")

        // Valid phone number verification (E.164 recommendation)
        #expect(InputSanitizer.isValidPhoneNumber("+94 77 123 4567") == true)
        #expect(InputSanitizer.isValidPhoneNumber("12345") == false) // too short (< 9 digits)
    }

    @Test("Sanitizes decimal entries by eliminating letters and redundant decimal separators")
    func decimalSanitization() {
        // Commas should be converted to periods
        #expect(InputSanitizer.sanitizeDecimal("12,50") == "12.50")

        // Letters and symbols should be stripped
        #expect(InputSanitizer.sanitizeDecimal("45.2kg") == "45.2")
        #expect(InputSanitizer.sanitizeDecimal("abc18.75xyz") == "18.75")

        // Multiple decimal points should only keep the first occurrence
        #expect(InputSanitizer.sanitizeDecimal("12.3.4") == "12.34")
    }

    @Test("Sanitizes integer entries to discard all non-digit characters")
    func integerSanitization() {
        #expect(InputSanitizer.sanitizeInteger("1868m") == "1868")
        #expect(InputSanitizer.sanitizeInteger("elevation: 2100") == "2100")
        #expect(InputSanitizer.sanitizeInteger("-500") == "500")
    }

    @Test("Sanitizes plucker employee codes into uppercase alphanumeric characters with hyphens")
    func pluckerIdSanitization() {
        #expect(InputSanitizer.sanitizePluckerId("plk-042") == "PLK-042")
        #expect(InputSanitizer.sanitizePluckerId("emp #105") == "EMP105")
    }

    @Test("Validates RFC compliant email addresses correctly")
    func emailValidation() {
        #expect(InputSanitizer.isValidEmail("manager@plantation.lk") == true)
        #expect(InputSanitizer.isValidEmail("supervisor@nuwaraeliya.estate.lk") == true)
        #expect(InputSanitizer.isValidEmail("invalid-email-format") == false)
        #expect(InputSanitizer.isValidEmail("name@domain") == false)
        #expect(InputSanitizer.isValidEmail("") == false)
    }
}
#endif

