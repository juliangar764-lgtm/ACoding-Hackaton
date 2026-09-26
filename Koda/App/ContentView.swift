//
//  ContentView.swift
//  Koda
//
//  Created by ADMIN UNACH on 21/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(filter: #Predicate<StudentProfile> {
        $0.id == "local-student"
    })
    private var profiles: [StudentProfile]

    private var profile: StudentProfile? {
        profiles.first
    }

    private var stage: OnboardingStage {
        OnboardingStage.resolve(
            hasProfile: profile != nil,
            needsReview: profile?.needsBasicReview,
            completedSteps: profile?.fundamentalsStep ?? 0,
            totalSteps: FundamentalsLesson.lessons.count
        )
    }

    var body: some View {
        Group {
            if let profile {
                switch stage {
                case .welcome:
                    welcomeFlow

                case .knowledge:
                    NavigationStack {
                        KnowledgeCheckView(profile: profile)
                    }

                case .fundamentals:
                    NavigationStack {
                        FundamentalsReviewView(profile: profile)
                    }

                case .topics:
                    // Cada pestaña gestiona su propia navegación.
                    MainTabView(profile: profile)
                }
            } else {
                welcomeFlow
            }
        }
        // Reinicia la navegación únicamente al cambiar de etapa.
        .id(stage)
        .preferredColorScheme(.light)
        .tint(KodaPalette.blue)
    }

    private var welcomeFlow: some View {
        NavigationStack {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                StudentProfile.self,
                TopicProgress.self
            ],
            inMemory: true
        )
}
