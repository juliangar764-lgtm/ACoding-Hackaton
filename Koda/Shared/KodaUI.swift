//
//  KodaUI.swift
//  Koda
//
//  Created by ADMIN UNACH on 23/09/26.
//

import SwiftUI

// MARK: - Colores compartidos

enum KodaPalette {
    static let ink = Color(
        red: 0.04,
        green: 0.09,
        blue: 0.24
    )

    static let secondary = Color(
        red: 0.28,
        green: 0.35,
        blue: 0.48
    )

    static let blue = Color(
        red: 0.10,
        green: 0.42,
        blue: 1
    )

    static let paleBlue = Color(
        red: 0.91,
        green: 0.96,
        blue: 1
    )

    static let line = Color(
        red: 0.85,
        green: 0.90,
        blue: 0.97
    )

    static let purple = Color(
        red: 0.40,
        green: 0.27,
        blue: 0.88
    )

    static let green = Color(
        red: 0.02,
        green: 0.48,
        blue: 0.30
    )
}

// MARK: - Estilos compartidos

extension View {
    func kodaPanel(
        fill: Color = .white,
        border: Color = KodaPalette.line
    ) -> some View {
        self
            .background(
                fill,
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(border, lineWidth: 1)
                    .allowsHitTesting(false)
            }
    }

    func kodaScreen() -> some View {
        self
            .foregroundStyle(KodaPalette.ink)
            .tint(KodaPalette.blue)
            .background {
                LinearGradient(
                    colors: [
                        .white,
                        Color(
                            red: 0.97,
                            green: 0.99,
                            blue: 1
                        )
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
    }
}

// MARK: - Botón principal

struct KodaPrimaryAction: View {
    let title: String
    var symbol: String = "arrow.right"
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Image(systemName: symbol)
                    .accessibilityHidden(true)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 24)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [
                                    KodaPalette.blue,
                                    Color(
                                        red: 0.02,
                                        green: 0.36,
                                        blue: 0.94
                                    )
                                ]
                                : [
                                    Color(
                                        red: 0.35,
                                        green: 0.42,
                                        blue: 0.54
                                    )
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

// MARK: - Profesor y mensaje

struct KodaTeacherMessage: View {
    let message: String

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            Image("KodaWelcome")
                .resizable()
                .scaledToFit()
                .frame(width: 82, height: 112)
                .accessibilityHidden(true)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(KodaPalette.ink)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .padding(16)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    KodaPalette.paleBlue,
                    in: RoundedRectangle(cornerRadius: 20)
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Koda: \(message)")
    }
}

// MARK: - Indicador de pasos

struct KodaStepDots: View {
    let current: Int
    var count = 4

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { step in
                Circle()
                    .fill(
                        step == current
                            ? KodaPalette.blue
                            : KodaPalette.line
                    )
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Icono de una tarjeta

struct KodaSymbolBadge: View {
    let symbol: String
    var color: Color = KodaPalette.blue

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 24, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: 52, height: 52)
            .background(
                color.opacity(0.10),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .accessibilityHidden(true)
    }
}

// MARK: - Ejemplo de código

struct KodaCodeCard: View {
    let code: String

    var body: some View {
        ScrollView(.horizontal) {
            Text(code)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(
                    Color(
                        red: 0.84,
                        green: 0.91,
                        blue: 1
                    )
                )
                .textSelection(.enabled)
                .padding(18)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(
                red: 0.10,
                green: 0.14,
                blue: 0.24
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }
}
