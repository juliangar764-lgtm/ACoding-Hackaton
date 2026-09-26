//
//  TopicProgress.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import Foundation
import SwiftData

@Model
final class TopicProgress {
    @Attribute(.unique)
    var topicID: String

    // Paso que se retomará. El primero es 0.
    var currentStep: Int

    var startedAt: Date
    var completedAt: Date?

    var isCompleted: Bool {
        completedAt != nil
    }

    init(topic: POOTopic) {
        self.topicID = topic.id
        self.currentStep = 0
        self.startedAt = Date()
        self.completedAt = nil
    }
}
