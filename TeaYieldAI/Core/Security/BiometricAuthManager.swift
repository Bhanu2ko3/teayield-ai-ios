import Foundation
import LocalAuthentication

/// Biometry hardware classification on the active iOS device.
enum BiometryType: String {
    case faceID = "Face ID"
    case touchID = "Touch ID"
    case none = "None"
}

/// Errors encountered during biometric evaluation.
enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case userCancelled
    case lockout
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric hardware is not available on this device."
        case .notEnrolled:
            return "No Face ID or Touch ID profiles are enrolled in device settings."
        case .userCancelled:
            return "Biometric authentication was cancelled."
        case .lockout:
            return "Biometrics locked out due to multiple failed attempts. Please enter your device passcode."
        case .failed(let message):
            return "Biometric authentication failed: \(message)"
        }
    }
}

/// Manages biometric authentication policies utilizing Apple LocalAuthentication framework.
final class BiometricAuthManager: @unchecked Sendable {

    static let shared = BiometricAuthManager()

    /// Detects the biometric sensor type present on the device.
    var biometryType: BiometryType {
        let context = LAContext()
        var error: NSError?
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            #if targetEnvironment(simulator)
            return .faceID
            #else
            return .none
            #endif
        }
    }

    /// Evaluates whether the device possesses enrolled and functional biometrics.
    var canEvaluateBiometrics: Bool {
        let context = LAContext()
        var error: NSError?
        let can = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        #if targetEnvironment(simulator)
        return true
        #else
        return can
        #endif
    }

    /// Prompts for Face ID or Touch ID verification with device passcode fallback.
    func authenticateWithPasscodeFallback(reason: String = "Authenticate to unlock TeaYield AI") async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                if success {
                    continuation.resume(returning: true)
                } else if let laError = error as? LAError {
                    switch laError.code {
                    case .userCancel:
                        continuation.resume(throwing: BiometricError.userCancelled)
                    case .biometryNotAvailable:
                        continuation.resume(throwing: BiometricError.notAvailable)
                    case .biometryNotEnrolled:
                        continuation.resume(throwing: BiometricError.notEnrolled)
                    case .biometryLockout:
                        continuation.resume(throwing: BiometricError.lockout)
                    default:
                        continuation.resume(throwing: BiometricError.failed(laError.localizedDescription))
                    }
                } else {
                    continuation.resume(throwing: BiometricError.failed(error?.localizedDescription ?? "Unknown failure"))
                }
            }
        }
    }
}
