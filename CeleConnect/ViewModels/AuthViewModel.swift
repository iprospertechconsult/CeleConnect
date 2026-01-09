//
//  AuthViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var user: User? = Auth.auth().currentUser
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MFA
    @Published var needsMFA: Bool = false
    @Published var mfaResolver: MultiFactorResolver?
    @Published var mfaVerificationID: String?
    
    // MARK: - Phone link / verification (post sign-in)
    @Published var isPhoneLinkedOrVerified: Bool = (Auth.auth().currentUser?.phoneNumber != nil)
    @Published var phoneVerificationID: String?
    @Published var phoneError: String?

    private let appleHelper = AppleSignInHelper()
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    func refreshUserState() async {
        self.user = Auth.auth().currentUser
        self.isPhoneLinkedOrVerified = (Auth.auth().currentUser?.phoneNumber != nil)
    }

    // 1) Send SMS code (regular phone verify flow)
    func startPhoneVerification(phoneNumber: String) async {
        phoneError = nil
        do {
            let id = try await PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            self.phoneVerificationID = id
        } catch {
            self.phoneError = error.localizedDescription
        }
    }

    // 2) Confirm code and LINK phone to current signed-in user
    func confirmAndLinkPhone(smsCode: String) async {
        phoneError = nil

        guard let verificationID = phoneVerificationID else {
            phoneError = "Missing verification ID. Please resend the code."
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            phoneError = "You must be signed in first."
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: smsCode
        )

        do {
            try await currentUser.link(with: credential)
            await refreshUserState()
        } catch {
            phoneError = error.localizedDescription
        }
    }

    
    func signInWithEmail(email: String, password: String) async {
            // sets needsMFA = true when required
        
        isLoading = true
            errorMessage = nil
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                self.user = result.user
                await refreshUserState()

                // ✅ ADD THIS LINE
                try await ensureUserDoc()

            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }

    // MARK: - Init
    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isPhoneLinkedOrVerified = (user?.phoneNumber != nil)
        }
    }

    deinit {
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }

    // MARK: - Apple Sign In
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await appleHelper.startSignInWithAppleFlow()
            self.user = result.user
            try await ensureUserDoc()
            await refreshUserState()

                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
    }

    // MARK: - Google Sign In
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil

        do {
            guard
                let clientID = FirebaseApp.app()?.options.clientID,
                let rootVC = UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap({ $0.windows })
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController
            else {
                throw NSError(domain: "Auth", code: -1)
            }

            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)

            guard let idToken = result.user.idToken?.tokenString else {
                throw NSError(domain: "Auth", code: -2)
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            let authResult = try await Auth.auth().signIn(with: credential)
            self.user = authResult.user
            
            try await ensureUserDoc()
            await refreshUserState()

                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
    }

    // MARK: - MFA Error Handling
    private func handleAuthError(_ error: Error) async throws {
        let nsError = error as NSError

        if nsError.code == AuthErrorCode.secondFactorRequired.rawValue {
            try await handleMFARequired(nsError)
        } else {
            errorMessage = nsError.localizedDescription
        }
    }

    private func handleMFARequired(_ error: NSError) async throws {
        guard
            let resolver = error.userInfo[AuthErrorUserInfoMultiFactorResolverKey]
                as? MultiFactorResolver,
            let phoneHint = resolver.hints.first as? PhoneMultiFactorInfo
        else {
            throw error
        }

        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(
            with: phoneHint,
            uiDelegate: nil,
            multiFactorSession: resolver.session
        )

        self.mfaResolver = resolver
        self.mfaVerificationID = verificationID
        self.needsMFA = true
    }

    // MARK: - Resolve MFA Sign-In
    func resolveMFA(code: String) async throws {
        guard
            let resolver = mfaResolver,
            let verificationID = mfaVerificationID
        else {
            throw NSError(domain: "MFA", code: -1)
        }

        let credential = PhoneAuthProvider.provider()
            .credential(withVerificationID: verificationID, verificationCode: code)

        let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
        let result = try await resolver.resolveSignIn(with: assertion)

        user = result.user
        needsMFA = false
        mfaResolver = nil
        mfaVerificationID = nil
    }

    // MARK: - MFA Enrollment
    func startEnrollPhoneMFA(phoneNumberE164: String) async throws -> String {
        guard let user else {
            throw NSError(domain: "MFA", code: -1)
        }

        let session = try await user.multiFactor.session()

        return try await PhoneAuthProvider.provider().verifyPhoneNumber(
            phoneNumberE164,
            uiDelegate: nil,
            multiFactorSession: session
        )
    }

    func finishEnrollPhoneMFA(
        verificationID: String,
        code: String,
        firstName: String = "SMS"
    ) async throws {

        guard let user else {
            throw NSError(domain: "MFA", code: -1)
        }

        let credential = PhoneAuthProvider.provider()
            .credential(withVerificationID: verificationID, verificationCode: code)

        let assertion = PhoneMultiFactorGenerator.assertion(with: credential)
        try await user.multiFactor.enroll(with: assertion, displayName: firstName)
    }
    
    func resetPhoneVerification() {
        phoneVerificationID = nil
        phoneError = nil
    }
    
    // MARK: - Email Sign Up
    func createAccountWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            user = result.user
            await refreshUserState()

            // Optional: send verification email
            try await result.user.sendEmailVerification()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Forgot Password
    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }


    // MARK: - Sign Out
    func signOut() {
        try? Auth.auth().signOut()
        user = nil
    }
    
    func ensureUserDoc() async throws {
        guard let uid = FirebaseRefs.currentUID else { return }

        let ref = FirebaseRefs.user(uid)
        let snap = try await ref.getDocument()
        if snap.exists { return }

        // Create a brand-new AppUser doc that matches AppUser.swift exactly
        try await ref.setData([
            // Identity
            "uid": uid,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),

            // Auth / Security
            "phoneNumber": Auth.auth().currentUser?.phoneNumber as Any,
            "isPhoneVerified": (Auth.auth().currentUser?.phoneNumber != nil),

            // Core Profile (filled during onboarding)
            "firstName": "",
            "birthday": "",                // yyyy-MM-dd
            "age": 0,

            "gender": AppUser.Gender.male.rawValue,          // placeholder
            "interestedIn": AppUser.Gender.female.rawValue,  // placeholder (onboarding will set correctly)

            // Discovery Preferences
            "distancePrefMiles": 0,         // 0 = Anywhere
            "lookingFor": AppUser.LookingFor.dating.rawValue,

            // Personality / Lifestyle
            "lifestyleHabits": NSNull(),    // optional
            "aboutMe": NSNull(),            // optional
            "interests": [],

            // Photos
            "photoURLs": [],
            "mainPhotoURL": NSNull(),       // optional

            // Location
            "location": NSNull(),           // optional {lat, lng}
            "city": NSNull(),               // optional
            "country": NSNull(),            // optional

            // App State
            "notificationsEnabled": true,
            "didCompleteOnboarding": false,
            "isDiscoverable": true
        ], merge: true)
    }


}
