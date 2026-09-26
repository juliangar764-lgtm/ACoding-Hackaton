//
//  KodaApp.swift
//  Koda
//
//  Created by ADMIN UNACH on 21/09/26.
//

import SwiftUI
import SwiftData

@main
struct KodaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                StudentProfile.self,
                TopicProgress.self
            ],
            inMemory: false
        )
    }
}
