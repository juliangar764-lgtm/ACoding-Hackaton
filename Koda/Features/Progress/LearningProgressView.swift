//
//  LearningProgressView.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import SwiftUI
import SwiftData

struct LearningProgressView: View {
    let onShowTopics: () -> Void

    @State private var reloadID = UUID()

    var body: some View {
        LearningProgressQueryView(
            onShowTopics: onShowTopics,
            onRetry: { reloadID = UUID() }
        )
        .id(reloadID)
        .kodaScreen()
        .toolbar(.hidden, for: .navigationBar)
    }
}

// Cambiar su identidad permite crear una consulta nueva al reintentar.
private struct LearningProgressQueryView: View {
    let onShowTopics: () -> Void
    let onRetry: () -> Void

    @Query private var records: [TopicProgress]
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Accede a los resultados antes de comprobar el error.
        let progress = LearningProgressSummary(
            topics: POOTopic.topics,
            records: records
        )

        Group {
            if _records.fetchError != nil {
                ContentUnavailableView {
                    Label(
                        "No pudimos cargar tu progreso",
                        systemImage: "exclamationmark.circle"
                    )
                } description: {
                    Text("Inténtalo de nuevo para consultar tu avance.")
                } actions: {
                    Button("Reintentar", action: onRetry)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
            } else {
                progressContent(progress)
            }
        }
    }

    private func progressContent(
        _ progress: LearningProgressSummary
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                summaryHeader(progress)
                experienceCard(progress)

                Text("Temas")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                VStack(spacing: 12) {
                    ForEach(POOTopic.topics) { topic in
                        topicRow(
                            topic,
                            state: progress.state(for: topic)
                        )
                    }
                }

                KodaTeacherMessage(
                    message: encouragement(for: progress)
                )

                KodaPrimaryAction(
                    title: "Ver temas",
                    action: onShowTopics
                )
            }
            .padding(24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Resumen

    private func summaryHeader(
        _ progress: LearningProgressSummary
    ) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(
                VStackLayout(alignment: .leading, spacing: 20)
            )
            : AnyLayout(
                HStackLayout(spacing: 20)
            )

        return layout {
            VStack(alignment: .leading, spacing: 10) {
                Text("Mi progreso")
                    .font(
                        .system(
                            .title,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .accessibilityAddTraits(.isHeader)

                Text(
                    "\(progress.completedTopicCount) de \(progress.totalTopicCount) temas completados"
                )
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)

            progressRing(progress)
        }
    }

    private func progressRing(
        _ progress: LearningProgressSummary
    ) -> some View {
        ZStack {
            Circle()
                .stroke(KodaPalette.paleBlue, lineWidth: 10)

            Circle()
                .trim(
                    from: 0,
                    to: CGFloat(progress.completionFraction)
                )
                .stroke(
                    KodaPalette.blue,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            Text("\(progress.percentage) %")
                .font(.title2.bold())
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(12)
        }
        .frame(width: 104, height: 104)
        .padding(5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progreso en POO")
        .accessibilityValue("\(progress.percentage) por ciento")
    }

    private func experienceCard(
        _ progress: LearningProgressSummary
    ) -> some View {
        HStack(spacing: 14) {
            KodaSymbolBadge(
                symbol: "star.fill",
                color: KodaPalette.purple
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("\(progress.experiencePoints) XP")
                    .font(.title2.bold())
                    .foregroundStyle(KodaPalette.blue)
                    .accessibilityLabel(
                        "\(progress.experiencePoints) puntos de experiencia"
                    )

                Text(
                    "\(LearningProgressSummary.pointsPerCompletedTopic) XP por cada tema completado."
                )
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .kodaPanel()
    }

    // MARK: - Estado de cada tema

    private func topicRow(
        _ topic: POOTopic,
        state: LearningProgressSummary.TopicState
    ) -> some View {
        HStack(spacing: 14) {
            KodaSymbolBadge(
                symbol: state.symbol,
                color: state.color
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(topic.title)
                    .font(.subheadline.weight(.semibold))

                Text(state.title)
                    .font(.caption)
                    .foregroundStyle(state.color)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .kodaPanel(
            fill: state == .completed
                ? KodaPalette.green.opacity(0.06)
                : .white,
            border: state == .completed
                ? KodaPalette.green.opacity(0.35)
                : KodaPalette.line
        )
        .accessibilityElement(children: .combine)
    }

    private func encouragement(
        for progress: LearningProgressSummary
    ) -> String {
        if progress.isComplete {
            return "¡Completaste todos los temas! Puedes volver a practicarlos cuando quieras."
        }

        if progress.completedTopicCount == 0 {
            return "Cada concepto cuenta. Empieza por clases y objetos y avanza a tu ritmo."
        }

        return "¡Vas avanzando! Sigue practicando para afianzar lo que has aprendido."
    }
}

// La apariencia pertenece a la vista; las reglas están en el modelo.
private extension LearningProgressSummary.TopicState {
    var title: String {
        switch self {
        case .notStarted:
            return "Sin empezar"
        case .inProgress:
            return "En progreso"
        case .completed:
            return "Completado"
        }
    }

    var symbol: String {
        switch self {
        case .notStarted:
            return "circle"
        case .inProgress:
            return "book"
        case .completed:
            return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .notStarted:
            return KodaPalette.secondary
        case .inProgress:
            return KodaPalette.blue
        case .completed:
            return KodaPalette.green
        }
    }
}

#Preview {
    NavigationStack {
        LearningProgressView(onShowTopics: {})
    }
    .preferredColorScheme(.light)
    .modelContainer(
        for: [StudentProfile.self, TopicProgress.self],
        inMemory: true
    )
}
