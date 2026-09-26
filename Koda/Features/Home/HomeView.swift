import SwiftUI
import SwiftData

struct HomeView: View {
    let profile: StudentProfile
    let onShowTopics: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title2) private var avatarSize = 88

    @State private var showFundamentals = false
    @State private var progressReloadID = UUID()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                greeting

                HomeLearningPathView(
                    onShowTopics: onShowTopics,
                    onRetry: { progressReloadID = UUID() }
                )
                .id(progressReloadID)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            fundamentalsButton
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
                .background(Color.white)
        }
        .kodaScreen()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showFundamentals) {
            FundamentalsLibraryView()
        }
    }

    // MARK: - Perfil

    private var greeting: some View {
        let avatar = ProfileAvatar(
            rawValue: profile.avatarName
        ) ?? .alex

        let size = min(avatarSize, 128)

        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(
                VStackLayout(alignment: .leading, spacing: 12)
            )
            : AnyLayout(
                HStackLayout(spacing: 14)
            )

        return layout {
            Image(avatar.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .scaleEffect(1.08)
                .background(KodaPalette.paleBlue, in: Circle())
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(
                            KodaPalette.line,
                            lineWidth: 1
                        )
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text("¡Hola, \(profile.name)!")
                    .font(
                        .system(
                            .title2,
                            design: .rounded,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(KodaPalette.ink)
                    .accessibilityAddTraits(.isHeader)

                Text("Sigamos aprendiendo juntos.")
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Acceso fijo a fundamentos

    private var fundamentalsButton: some View {
        Button {
            showFundamentals = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "book")
                    .font(.title3)

                Text("Repasar fundamentos")
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(KodaPalette.purple)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                KodaPalette.purple.opacity(0.09),
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Repasar fundamentos")
    }
}

// Mantiene la consulta y su reintento en la sección de progreso.
private struct HomeLearningPathView: View {
    let onShowTopics: () -> Void
    let onRetry: () -> Void

    @Query private var records: [TopicProgress]

    var body: some View {
        let progress = LearningProgressSummary(
            topics: POOTopic.topics,
            records: records
        )

        Group {
            if _records.fetchError != nil {
                errorPanel
            } else {
                VStack(alignment: .leading, spacing: 14) {
                    progressCard(progress)

                    VStack(spacing: 8) {
                        ForEach(POOTopic.topics) { topic in
                            topicRow(
                                topic,
                                state: progress.state(for: topic)
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recorrido

    private func progressCard(
        _ progress: LearningProgressSummary
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Tu camino en POO")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Button("Ver temas", action: onShowTopics)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KodaPalette.blue)
                    .padding(.horizontal, 4)
                    .frame(minHeight: 44)
                    .buttonStyle(.plain)
            }

            Text(
                "\(progress.completedTopicCount) de \(progress.totalTopicCount) temas completados"
            )
            .font(.subheadline)
            .foregroundStyle(KodaPalette.secondary)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 0) {
                ForEach(POOTopic.topics) { topic in
                    let status = appearance(
                        for: progress.state(for: topic)
                    )

                    Image(systemName: status.symbol)
                        .font(
                            .system(size: 15, weight: .semibold)
                        )
                        .foregroundStyle(status.color)
                        .frame(width: 18, height: 18)

                    if topic.id != POOTopic.topics.last?.id {
                        Rectangle()
                            .fill(KodaPalette.line)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 4)
            .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .kodaPanel()
    }

    // MARK: - Tarjetas compactas

    private func topicRow(
        _ topic: POOTopic,
        state: LearningProgressSummary.TopicState
    ) -> some View {
        let status = appearance(for: state)

        return HStack(spacing: 12) {
            Image(systemName: status.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(status.color)
                .frame(width: 22)
                .accessibilityHidden(true)

            Image(systemName: topicSymbol(for: topic.id))
                .font(.system(size: 21, weight: .medium))
                .foregroundStyle(KodaPalette.purple)
                .frame(width: 40, height: 40)
                .background(
                    KodaPalette.purple.opacity(0.09),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(topic.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KodaPalette.ink)

                Text(
                    state == .notStarted
                        ? topic.subtitle
                        : status.title
                )
                .font(.caption)
                .foregroundStyle(status.color)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .kodaPanel(
            fill: state == .completed
                ? KodaPalette.green.opacity(0.06)
                : .white,
            border: state == .completed
                ? KodaPalette.green.opacity(0.35)
                : KodaPalette.line
        )
        .accessibilityElement(children: .combine)
        .accessibilityValue(status.title)
    }

    // MARK: - Error de lectura

    private var errorPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "No pudimos cargar tu progreso",
                systemImage: "exclamationmark.circle"
            )
            .font(.headline)

            Text("Inténtalo de nuevo para consultar tu avance.")
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)

            Button("Reintentar", action: onRetry)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            Button("Ver temas", action: onShowTopics)
                .frame(minHeight: 44)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kodaPanel()
    }

    private func appearance(
        for state: LearningProgressSummary.TopicState
    ) -> (title: String, symbol: String, color: Color) {
        switch state {
        case .notStarted:
            return (
                "Sin empezar",
                "circle",
                KodaPalette.secondary
            )

        case .inProgress:
            return (
                "En progreso",
                "record.circle",
                KodaPalette.blue
            )

        case .completed:
            return (
                "Completado",
                "checkmark.circle.fill",
                KodaPalette.green
            )
        }
    }

    private func topicSymbol(for id: String) -> String {
        switch id {
        case "classes-and-objects":
            return "cube"

        case "properties-and-methods":
            return "slider.horizontal.3"

        case "inheritance":
            return "arrow.triangle.branch"

        case "encapsulation":
            return "lock"

        case "polymorphism":
            return "arrow.triangle.2.circlepath"

        default:
            return "book.closed"
        }
    }
}

// La preview usa las pestañas reales y un perfil temporal.
private struct HomePreviewHost: View {
    @Environment(\.modelContext) private var modelContext
    @State private var profile: StudentProfile?

    var body: some View {
        Group {
            if let profile {
                MainTabView(profile: profile)
            } else {
                ProgressView("Preparando vista previa…")
            }
        }
        .task {
            guard profile == nil else { return }

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

#Preview("Inicio con pestañas") {
    HomePreviewHost()
        .preferredColorScheme(.light)
        .modelContainer(
            for: [StudentProfile.self, TopicProgress.self],
            inMemory: true
        )
}
