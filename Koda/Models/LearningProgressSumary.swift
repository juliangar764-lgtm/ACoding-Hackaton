//
//  LearningProgressSumary.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

struct LearningProgressSummary {
    enum TopicState: Equatable {
        case notStarted
        case inProgress
        case completed
    }

    static let pointsPerCompletedTopic = 100

    private let topicIDs: Set<String>
    private let startedTopicIDs: Set<String>
    private let completedTopicIDs: Set<String>

    // Lee los modelos en el mismo actor que utiliza la interfaz.
    @MainActor
    init(topics: [POOTopic], records: [TopicProgress]) {
        let knownIDs = Set(topics.map(\.id))

        topicIDs = knownIDs

        startedTopicIDs = Set(records.map(\.topicID))
            .intersection(knownIDs)

        completedTopicIDs = Set(
            records
                .filter { $0.isCompleted }
                .map(\.topicID)
        )
        .intersection(knownIDs)
    }

    var totalTopicCount: Int {
        topicIDs.count
    }

    var completedTopicCount: Int {
        completedTopicIDs.count
    }

    var completionFraction: Double {
        guard totalTopicCount > 0 else { return 0 }

        return Double(completedTopicCount) / Double(totalTopicCount)
    }

    var percentage: Int {
        Int((completionFraction * 100).rounded())
    }

    var experiencePoints: Int {
        completedTopicCount * Self.pointsPerCompletedTopic
    }

    var isComplete: Bool {
        totalTopicCount > 0 && completedTopicCount == totalTopicCount
    }

    func state(for topic: POOTopic) -> TopicState {
        if completedTopicIDs.contains(topic.id) {
            return .completed
        }

        if startedTopicIDs.contains(topic.id) {
            return .inProgress
        }

        return .notStarted
    }
}
