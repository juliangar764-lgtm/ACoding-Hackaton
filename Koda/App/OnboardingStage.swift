//
//  OnboardingStage.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//

enum OnboardingStage: Hashable {
    case welcome
    case knowledge
    case fundamentals
    case topics

    static func resolve(
        hasProfile: Bool,
        needsReview: Bool?,
        completedSteps: Int,
        totalSteps: Int
    ) -> Self {
        guard hasProfile else {
            return .welcome
        }

        guard let needsReview else {
            return .knowledge
        }

        if needsReview && completedSteps < totalSteps {
            return .fundamentals
        }

        return .topics
    }
}
