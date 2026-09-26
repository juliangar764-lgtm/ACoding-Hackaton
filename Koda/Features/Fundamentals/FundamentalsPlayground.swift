//
//  FundamentalsPlayground.swift
//  Koda
//
//  Created by ADMIN UNACH on 23/09/26.
//

import SwiftUI

struct FundamentalsPlayground: View {
    let lessonID: String

    @State private var speed = 20.0
    @State private var greenLight = false
    @State private var repetitions = 3
    @State private var greetings = 0

    var body: some View {
        VStack(spacing: 18) {
            switch lessonID {
            case "variables":
                variablesExample

            case "conditions":
                conditionsExample

            case "loops":
                loopsExample

            case "functions":
                functionsExample

            default:
                ContentUnavailableView(
                    "Ejemplo no disponible",
                    systemImage: "book.closed",
                    description: Text("Elige otro tema del repaso.")
                )
            }
        }
        .foregroundStyle(KodaPalette.ink)
        .tint(KodaPalette.blue)
    }

    // MARK: - Variables

    private var variablesExample: some View {
        VStack(spacing: 18) {
            carScene

            KodaCodeCard(
                code: "var velocidad = \(Int(speed))"
            )

            VStack(spacing: 8) {
                HStack {
                    Text("Velocidad")
                        .font(.headline)

                    Spacer()

                    Text("\(Int(speed))")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(KodaPalette.blue)
                }

                Slider(
                    value: $speed,
                    in: 0...150,
                    step: 10
                )
                .accessibilityLabel("Velocidad")
                .accessibilityValue("\(Int(speed))")

                HStack {
                    Text("0")
                    Spacer()
                    Text("50")
                    Spacer()
                    Text("100")
                    Spacer()
                    Text("150")
                }
                .font(.caption)
                .foregroundStyle(KodaPalette.secondary)
                .accessibilityHidden(true)
            }
        }
    }

    // MARK: - Condiciones

    private var conditionsExample: some View {
        VStack(spacing: 18) {
            HStack(spacing: 24) {
                trafficLight

                VStack(spacing: 12) {
                    KodaCarDrawing()

                    Text(greenLight ? "Avanza" : "Espera")
                        .font(.headline)
                        .foregroundStyle(
                            greenLight
                                ? KodaPalette.green
                                : KodaPalette.ink
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .kodaPanel(fill: KodaPalette.paleBlue)

            Toggle(
                "Semáforo en verde",
                isOn: $greenLight
            )
            .font(.subheadline.weight(.semibold))

            KodaCodeCard(
                code: """
                let semaforo = "\(greenLight ? "verde" : "rojo")"

                if semaforo == "verde" {
                    print("Avanza")
                } else {
                    print("Espera")
                }
                """
            )
        }
    }

    private var trafficLight: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(
                    greenLight
                        ? Color.red.opacity(0.15)
                        : Color.red
                )

            Circle()
                .fill(Color.yellow.opacity(0.15))

            Circle()
                .fill(
                    greenLight
                        ? Color.green
                        : Color.green.opacity(0.15)
                )
        }
        .frame(width: 28, height: 108)
        .padding(14)
        .background(
            KodaPalette.ink,
            in: RoundedRectangle(cornerRadius: 18)
        )
        .accessibilityHidden(true)
    }

    // MARK: - Bucles

    private var loopsExample: some View {
        VStack(spacing: 18) {
            VStack(spacing: 10) {
                ForEach(0..<repetitions, id: \.self) { index in
                    HStack {
                        Text("\(index + 1)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(KodaPalette.secondary)

                        Text("Hola")
                            .font(.headline)

                        Spacer()

                        Image(systemName: "checkmark")
                            .foregroundStyle(KodaPalette.green)
                            .accessibilityHidden(true)
                    }
                    .padding(12)
                    .kodaPanel(fill: KodaPalette.paleBlue)
                    .accessibilityElement(children: .combine)
                }
            }

            Stepper(
                "Repeticiones: \(repetitions)",
                value: $repetitions,
                in: 1...5
            )
            .font(.subheadline.weight(.semibold))

            KodaCodeCard(
                code: """
                for _ in 1...\(repetitions) {
                    print("Hola")
                }
                """
            )
        }
    }

    // MARK: - Funciones

    private var functionsExample: some View {
        VStack(spacing: 18) {
            VStack(spacing: 12) {
                KodaSymbolBadge(
                    symbol: "function",
                    color: KodaPalette.purple
                )

                Text(
                    greetings == 0
                        ? "La función está lista"
                        : "Hola"
                )
                .font(.title3.bold())

                Text(
                    greetings == 0
                        ? "Llámala para ver el resultado."
                        : "Llamadas realizadas: \(greetings)"
                )
                .font(.subheadline)
                .foregroundStyle(KodaPalette.secondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(24)
            .kodaPanel(fill: KodaPalette.paleBlue)

            KodaCodeCard(
                code: """
                func saludar() {
                    print("Hola")
                }
                """
            )

            Button {
                greetings += 1
            } label: {
                Label(
                    "Ejecutar saludar()",
                    systemImage: "play.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(8)
                .foregroundStyle(KodaPalette.green)
                .kodaPanel(
                    fill: KodaPalette.green.opacity(0.08),
                    border: KodaPalette.green.opacity(0.4)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Escena del coche

    private var carScene: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(
                        red: 0.88,
                        green: 0.94,
                        blue: 1
                    ),
                    .white
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .bottom, spacing: 16) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(KodaPalette.line)
                    .frame(width: 32, height: 68)

                RoundedRectangle(cornerRadius: 8)
                    .fill(KodaPalette.paleBlue)
                    .frame(width: 48, height: 88)

                Spacer()

                RoundedRectangle(cornerRadius: 8)
                    .fill(KodaPalette.line)
                    .frame(width: 44, height: 74)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 38)

            Rectangle()
                .fill(
                    Color(
                        red: 0.63,
                        green: 0.70,
                        blue: 0.80
                    )
                )
                .frame(height: 42)

            HStack(spacing: 20) {
                ForEach(0..<6) { _ in
                    Capsule()
                        .fill(.white.opacity(0.8))
                        .frame(height: 3)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)

            KodaCarDrawing()
                .padding(.bottom, 28)
        }
        .frame(height: 168)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityHidden(true)
    }
}

// MARK: - Coche dibujado con SwiftUI

private struct KodaCarDrawing: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(KodaPalette.blue.gradient)
                .frame(width: 96, height: 50)
                .offset(x: -5, y: -10)

            HStack(spacing: 5) {
                window
                window
            }
            .frame(width: 74, height: 27)
            .offset(x: -5, y: -16)

            RoundedRectangle(cornerRadius: 17)
                .fill(KodaPalette.blue.gradient)
                .frame(width: 146, height: 39)
                .offset(y: 13)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.yellow.opacity(0.9))
                .frame(width: 12, height: 9)
                .offset(x: 65, y: 9)

            HStack(spacing: 64) {
                wheel
                wheel
            }
            .offset(y: 31)
        }
        .frame(width: 160, height: 92)
        .accessibilityHidden(true)
    }

    private var window: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(
                Color(
                    red: 0.70,
                    green: 0.86,
                    blue: 1
                )
            )
    }

    private var wheel: some View {
        Circle()
            .fill(KodaPalette.ink)
            .frame(width: 30, height: 30)
            .overlay {
                Circle()
                    .fill(
                        Color(
                            red: 0.69,
                            green: 0.78,
                            blue: 0.89
                        )
                    )
                    .padding(7)
            }
    }
}

#Preview("Variables") {
    ScrollView {
        FundamentalsPlayground(lessonID: "variables")
            .padding(24)
    }
    .kodaScreen()
    .preferredColorScheme(.light)
}
