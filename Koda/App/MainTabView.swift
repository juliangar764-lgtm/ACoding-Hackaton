//
//  MainTabView.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    let profile: StudentProfile

    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(
                AppTab.home.title,
                systemImage: AppTab.home.systemImage,
                value: AppTab.home
            ) {
                NavigationStack {
                    HomeView(profile: profile) {
                        selectedTab = .topics
                    }
                }
            }

            Tab(
                AppTab.topics.title,
                systemImage: AppTab.topics.systemImage,
                value: AppTab.topics
            ) {
                NavigationStack {
                    POOTopicsView(profile: profile)
                }
            }

            Tab(
                AppTab.progress.title,
                systemImage: AppTab.progress.systemImage,
                value: AppTab.progress
            ) {
                NavigationStack {
                    LearningProgressView {
                        selectedTab = .topics
                    }
                }
            }

            Tab(
                AppTab.profile.title,
                systemImage: AppTab.profile.systemImage,
                value: AppTab.profile
            ) {
                NavigationStack {
                    ProfileView(profile: profile) {
                        selectedTab = .progress
                    }
                }
            }
        }
        .tint(KodaPalette.blue)
    }
}

// MARK: - Vista previa con un perfil temporal

private struct MainTabPreviewHost: View {
    @Environment(\.modelContext) private var modelContext
    @State private var profile: StudentProfile?

    var body: some View {
        Group {
            if let profile {
                MainTabView(profile: profile)
            } else {
                ProgressView("Preparando Koda…")
            }
        }
        .task {
            guard profile == nil else {
                return
            }

            let student = StudentProfile(
                name: "Alex",
                avatarName: ProfileAvatar.alex.rawValue
            )

            student.needsBasicReview = false

            modelContext.insert(student)
            profile = student
        }
    }
}

#Preview {
    MainTabPreviewHost()
        .preferredColorScheme(.light)
        .modelContainer(
            for: [
                StudentProfile.self,
                TopicProgress.self
            ],
            inMemory: true
        )
}
