//
//  OnboardingFlowView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                switch onboardingVM.step {
                case .firstName:
                    FirstNameStepView(vm: onboardingVM)

                case .birthday:
                    BirthdayStepView(vm: onboardingVM)

                case .gender:
                    GenderStepView(vm: onboardingVM)

                case .distance:
                    DistanceStepView(vm: onboardingVM)

                case .lookingFor:
                    LookingForStepView(vm: onboardingVM)

                case .lifestyle:
                    LifestyleStepView(vm: onboardingVM)

                case .aboutYou:
                    AboutYouStepView(vm: onboardingVM)

                case .interests:
                    InterestsStepView(vm: onboardingVM)

                case .photos:
                    PhotosStepView(vm: onboardingVM)

                case .location:
                    LocationStepView(vm: onboardingVM)

                case .notifications:
                    NotificationsStepView(vm: onboardingVM)

                case .tutorial:
                    TutorialStepView(vm: onboardingVM)
                }
            }
        }
    }
}
