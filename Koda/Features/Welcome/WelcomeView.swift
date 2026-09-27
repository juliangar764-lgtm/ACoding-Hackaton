//
//  WelcomeView.swift
//  Koda
//
//  Created by ADMIN UNACH on 21/09/26.
//


import SwiftUI
import SwiftData

struct WelcomeView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric(relativeTo: .largeTitle)
    private var titleSize = 48

    private let primaryBlue = Color(
        red: 0.10,
        green: 0.42,
        blue: 1
    )

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    professorImage(
                        height: min(
                            280,
                            max(170, geometry.size.height * 0.42)
                        )
                    )

                    introduction
                    features
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            footer
        }
        .background {
            background
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Fondo

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.03, blue: 0.13),
                    Color(red: 0.03, green: 0.09, blue: 0.29),
                    Color(red: 0.04, green: 0.16, blue: 0.43)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    primaryBlue.opacity(0.2),
                    .clear
                ],
                center: .top,
                startRadius: 20,
                endRadius: 340
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Profesor

    private func professorImage(height: CGFloat) -> some View {
        Image("KodaWelcome")
            .resizable()
            .scaledToFit()
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    // MARK: - Presentación

    private var introduction: some View {
        VStack(spacing: 12) {
            Text("Koda")
                .font(
                    .system(
                        size: titleSize,
                        weight: .heavy,
                        design: .rounded
                    )
                )
                .accessibilityAddTraits(.isHeader)

            Text("Entiende POO, paso a paso con Swift")
                .font(.headline)

            Text(
                """
                Aprende, practica y resuelve tus dudas \
                con tu profesor virtual.
                """
            )
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.75))
            .lineSpacing(3)
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Tarjetas

    private var features: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(
                HStackLayout(alignment: .top, spacing: 10)
            )

        return layout {
            featureCard(
                icon: "book.closed.fill",
                title: "Aprende",
                description: "Conceptos\nclaros"
            )

            featureCard(
                icon: "hand.tap.fill",
                title: "Practica",
                description: "Ejercicios\ninteractivos"
            )

            featureCard(
                icon: "bubble.left.and.bubble.right.fill",
                title: "Pregunta",
                description: "Resuelve\ntus dudas"
            )
        }
    }

    private func featureCard(
        icon: String,
        title: String,
        description: String
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    Color(red: 0.72, green: 0.74, blue: 1)
                )
                .frame(minHeight: 32)
                .accessibilityHidden(true)

            Text(title)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.white)

            Text(description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
                .lineSpacing(2)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 6)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    .white.opacity(0.08),
                    lineWidth: 1
                )
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Navegación al perfil

    private var footer: some View {
        VStack(spacing: 14) {
            NavigationLink {
                CreateProfileView()
                    .toolbar(.visible, for: .navigationBar)
            } label: {
                HStack(spacing: 12) {
                    Text("Comenzar")

                    Image(systemName: "arrow.right")
                        .accessibilityHidden(true)
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(primaryBlue)
                }
            }
            .buttonStyle(.plain)

            Text("Aprende a tu ritmo, paso a paso.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
    .preferredColorScheme(.light)
    .modelContainer(
        for: StudentProfile.self,
        inMemory: true
    )
}
