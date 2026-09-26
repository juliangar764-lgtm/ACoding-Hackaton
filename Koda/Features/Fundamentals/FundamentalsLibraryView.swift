//
//  FundamentalsLibraryView.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import SwiftUI

struct FundamentalsLibraryView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(
                        "Elige un concepto para repasar y experimentar."
                    )
                    .font(.subheadline)
                    .foregroundStyle(KodaPalette.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    ForEach(FundamentalsLesson.lessons) { lesson in
                        NavigationLink {
                            lessonPage(lesson)
                        } label: {
                            lessonRow(lesson)
                        }
                        .buttonStyle(.plain)
                    }

                    KodaTeacherMessage(
                        message: """
                        Puedes volver a estos ejemplos \
                        siempre que lo necesites.
                        """
                    )
                }
                .padding(24)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .kodaScreen()
            .navigationTitle("Fundamentos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbar {
                closeToolbar
            }
        }
    }

    // MARK: - Selección del concepto

    private func lessonRow(
        _ lesson: FundamentalsLesson
    ) -> some View {
        let style = appearance(for: lesson.id)

        return HStack(spacing: 14) {
            KodaSymbolBadge(
                symbol: style.symbol,
                color: style.color
            )

            Text(lesson.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(KodaPalette.secondary)
                .accessibilityHidden(true)
        }
        .foregroundStyle(KodaPalette.ink)
        .padding(16)
        .kodaPanel()
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Explicación y ejemplo interactivo

    private func lessonPage(
        _ lesson: FundamentalsLesson
    ) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(lesson.explanation)
                    .font(.body)
                    .foregroundStyle(KodaPalette.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Prueba el ejemplo")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                FundamentalsPlayground(lessonID: lesson.id)
                    .id(lesson.id)
            }
            .padding(24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .kodaScreen()
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            closeToolbar
        }
    }

    // MARK: - Cierre de la biblioteca

    @ToolbarContentBuilder
    private var closeToolbar: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Cerrar") {
                dismiss()
            }
        }
    }

    // MARK: - Iconos y colores

    private func appearance(
        for id: String
    ) -> (symbol: String, color: Color) {
        switch id {
        case "variables":
            return (
                "xmark",
                KodaPalette.purple
            )

        case "conditions":
            return (
                "arrow.triangle.branch",
                .orange
            )

        case "loops":
            return (
                "arrow.triangle.2.circlepath",
                KodaPalette.green
            )

        case "functions":
            return (
                "function",
                KodaPalette.blue
            )

        default:
            return (
                "book.closed",
                KodaPalette.blue
            )
        }
    }
}

#Preview {
    FundamentalsLibraryView()
        .preferredColorScheme(.light)
}
