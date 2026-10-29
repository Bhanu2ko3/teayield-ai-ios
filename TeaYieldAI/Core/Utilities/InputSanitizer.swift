import Foundation

/// Centralized utility providing defensive input sanitization and domain constraint validation.
enum InputSanitizer {

    /// Filters phone numbers to strictly permit a single leading '+' and digits, discarding any letters or invalid symbols.
    static func sanitizePhoneNumber(_ input: String) -> String {
        var result = ""
        var hasLeadingPlus = false

        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        for (index, char) in trimmed.enumerated() {
            if char == "+" && index == 0 && !hasLeadingPlus {
                result.append(char)
                hasLeadingPlus = true
            } else if char.isNumber {
                result.append(char)
            } else if char == " " || char == "-" {
                if let last = result.last, last != " " && last != "-" {
                    result.append(char)
                }
            }
        }
        return result
    }

    /// Validates phone number length adhering to the E.164 international standard (9 to 15 digits).
    static func isValidPhoneNumber(_ candidate: String) -> Bool {
        let digitsOnly = candidate.filter { $0.isNumber }
        return digitsOnly.count >= 9 && digitsOnly.count <= 15
    }

    /// Sanitizes decimal numeric inputs by normalizing commas to periods and eliminating letters and extra decimals.
    static func sanitizeDecimal(_ input: String) -> String {
        let normalized = input.replacingOccurrences(of: ",", with: ".")
        var result = ""
        var hasDecimalPoint = false

        for char in normalized {
            if char.isNumber {
                result.append(char)
            } else if char == "." && !hasDecimalPoint {
                result.append(char)
                hasDecimalPoint = true
            }
        }
        return result
    }

    /// Sanitizes integer inputs, discarding all letters, punctuation, and symbols.
    static func sanitizeInteger(_ input: String) -> String {
        return input.filter { $0.isNumber }
    }

    /// Sanitizes plucker employee identifiers into capitalized alphanumeric format with hyphens.
    static func sanitizePluckerId(_ input: String) -> String {
        return input.uppercased().filter { $0.isLetter || $0.isNumber || $0 == "-" }
    }

    /// Evaluates candidate strings against standard RFC email criteria.
    static func isValidEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: candidate.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

