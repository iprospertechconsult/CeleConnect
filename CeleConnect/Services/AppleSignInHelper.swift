//
//  AppleSignInHelper.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import UIKit

@MainActor
final class AppleSignInHelper: NSObject {

    private var currentNonce: String?
    private var continuation: CheckedContinuation<AuthDataResult, Error>?

    func startSignInWithAppleFlow() async throws -> AuthDataResult {
        let nonce = randomNonceString()
        currentNonce = nonce

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // MARK: - Nonce helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            if status != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status)")
            }

            for random in randoms {
                if remainingLength == 0 { break }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    private func finish(_ result: Result<AuthDataResult, Error>) {
        guard let continuation = continuation else { return }
        self.continuation = nil
        self.currentNonce = nil

        switch result {
        case .success(let authResult):
            continuation.resume(returning: authResult)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInHelper: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8),
            let nonce = currentNonce
        else {
            finish(.failure(NSError(
                domain: "AppleSignIn",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing token/nonce"]
            )))
            return
        }

        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                Task { @MainActor in self.finish(.failure(error)) }
                return
            }

            guard let result = result else {
                Task { @MainActor in
                    self.finish(.failure(NSError(
                        domain: "AppleSignIn",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "No auth result"]
                    )))
                }
                return
            }

            Task { @MainActor in self.finish(.success(result)) }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        finish(.failure(error))
    }
}

// MARK: - Presentation Anchor (no deprecated keyWindow)
extension AppleSignInHelper: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        // Prefer the window that is key (if any), otherwise the first visible window
        if let window = scenes
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            return window
        }

        if let window = scenes
            .flatMap({ $0.windows })
            .first(where: { !$0.isHidden }) {
            return window
        }

        // If we truly have no windows, fail fast with a clear error.
        // This should basically never happen in a real running app.
        fatalError("No active window found for Sign in with Apple presentation anchor.")
    }
}
