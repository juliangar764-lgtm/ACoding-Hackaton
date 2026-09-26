//
//  POOTopicsView.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//

import SwiftUI
import SwiftData

struct POOTopicsView: View {
    let profile: StudentProfile

    @State private var reloadID = UUID()

    var body: some View {
        POOTopicsContentView(profile: profile) {
            reloadID = UUID()
        }
        .id(reloadID)
        .kodaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct POOTopicsContentView: View {
    let profile: StudentProfile
    let onRetry: () -> Void

    @Query private var records: [TopicProgress]

    @State private var expandedTopicID: String?
    @State private var showFundamentals = false

    var body: some View {
        // Lee los registros antes de consultar el error.
        let summary = LearningProgressSummary(
            topics: POOTopic.topics,
            records: records
        )

        Group {
            if _records.fetchError != nil {
                ContentUnavailableView {
                    Label(
                        "No pudimos cargar tu progreso",
                        systemImage: "exclamationmark.triangle"
                    )
                } description: {
                    Text(
                        "Vuelve a intentarlo para consultar tus temas."
                    )
                } actions: {
                    Button("Reintentar", action: onRetry)
                        .buttonStyle(.borderedProminent)
                }
            } else {
                content(summary: summary)
            }
        }
        .sheet(isPresented: $showFundamentals) {
            FundamentalsLibraryView()
        }
    }

    // MARK: - Contenido

    private func content(
        summary: LearningProgressSummary
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Temas de POO")
                        .font(
                            .system(
                                .title,
                                design: .rounded,
                                weight: .bold
                            )
                        )
                        .accessibilityAddTraits(.isHeader)

                    Text("Explora los temas y avanza a tu ritmo.")
                        .foregroundStyle(KodaPalette.secondary)

                    Text(
                        "\(summary.completedTopicCount) de \(summary.totalTopicCount) temas completados"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KodaPalette.blue)
                }

                VStack(spacing: 12) {
                    ForEach(POOTopic.topics) { topic in
                        if let lesson = POOLesson.lesson(for: topic) {
                            lessonLink(
                                lesson,
                                state: summary.state(for: topic)
                            )
                        } else {
                            conceptCard(topic)
                        }
                    }
                }

                KodaTeacherMessage(
                    message: """
                    ¡Vamos, \(profile.name)! Aprende con los ejemplos \
                    y pon a prueba lo que descubriste.
                    """
                )

                Button {
                    showFundamentals = true
                } label: {
                    Label(
                        "Repasar fundamentos",
                        systemImage: "book"
                    )
                    .font(.headline)
                    .foregroundStyle(KodaPalette.purple)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 44
                    )
                    .padding(12)
                    .kodaPanel(
                        fill: KodaPalette.purple.opacity(0.08)
                    )
                    .contentShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(20)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Lecciones disponibles

    private func lessonLink(
        _ lesson: POOLesson,
        state: LearningProgressSummary.TopicState
    ) -> some View {
        NavigationLink {
            POOLessonView(lesson: lesson)
        } label: {
            topicLabel(
                lesson.topic,
                detail: lessonAction(for: state),
                trailingSymbol: state == .completed
                    ? "checkmark.circle.fill"
                    : "chevron.right",
                completed: state == .completed
            )
        }
        .buttonStyle(.plain)
        .kodaPanel(
            fill: state == .completed
                ? KodaPalette.green.opacity(0.07)
                : .white,
            border: state == .completed
                ? KodaPalette.green.opacity(0.35)
                : KodaPalette.line
        )
    }

    private func lessonAction(
        for state: LearningProgressSummary.TopicState
    ) -> String {
        switch state {
        case .notStarted:
            return "Comenzar lección"

        case .inProgress:
            return "En progreso · Continuar lección"

        case .completed:
            return "Completado · Ver resultado"
        }
    }

    // MARK: - Explicaciones de los demás temas

    private func conceptCard(
        _ topic: POOTopic
    ) -> some View {
        let expanded = expandedTopicID == topic.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                expandedTopicID = expanded ? nil : topic.id
            } label: {
                topicLabel(
                    topic,
                    detail: "Leer explicación",
                    trailingSymbol: expanded
                        ? "chevron.down"
                        : "chevron.right"
                )
            }
            .buttonStyle(.plain)
            .accessibilityValue(
                expanded ? "Expandido" : "Contraído"
            )
            .accessibilityHint(
                expanded
                    ? "Ocultar explicación"
                    : "Mostrar explicación"
            )

            if expanded {
                Divider()
                    .padding(.horizontal, 16)

                Text(topic.explanation)
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .padding(16)
            }
        }
        .kodaPanel(
            border: expanded
                ? KodaPalette.blue
                : KodaPalette.line
        )
    }

    // MARK: - Apariencia de las tarjetas

    private func topicLabel(
        _ topic: POOTopic,
        detail: String,
        trailingSymbol: String,
        completed: Bool = false
    ) -> some View {
        let appearance = appearance(for: topic.id)

        return HStack(alignment: .top, spacing: 12) {
            KodaSymbolBadge(
                symbol: appearance.symbol,
                color: appearance.color
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(topic.title)
                    .font(.headline)
                    .foregroundStyle(KodaPalette.ink)

                Text(topic.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)

                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(
                        completed
                            ? KodaPalette.green
                            : KodaPalette.blue
                    )
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            Image(systemName: trailingSymbol)
                .foregroundStyle(
                    completed
                        ? KodaPalette.green
                        : KodaPalette.secondary
                )
                .accessibilityHidden(true)
        }
        .padding(16)
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    private func appearance(
        for id: String
    ) -> (symbol: String, color: Color) {
        switch id {
        case "classes-and-objects":
            return ("car.fill", KodaPalette.blue)

        case "properties-and-methods":
            return ("cube.fill", .orange)

        case "inheritance":
            return ("arrow.triangle.branch", KodaPalette.purple)

        case "encapsulation":
            return ("lock", KodaPalette.secondary)

        case "polymorphism":
            return ("circle.grid.2x2.fill", KodaPalette.green)

        default:
            return ("book.closed", KodaPalette.blue)
        }
    }
}

// MARK: - Vista previa

#Preview("Temas de POO") {
    let profile = StudentProfile(
        name: "Alex",
        avatarName: ProfileAvatar.alex.rawValue
    )

    NavigationStack {
        POOTopicsView(profile: profile)
    }
    .modelContainer(
        for: [
            StudentProfile.self,
            TopicProgress.self
        ],
        inMemory: true
    )
    .preferredColorScheme(.light)
}
