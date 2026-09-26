//
//  CarIlustrationView.swift
//  Koda
//
//  Created by ADMIN UNACH on 24/09/26.
//

import SwiftUI

struct CarIllustrationView: View {
    let color: LearningCar.PaintColor
    let doors: LearningCar.DoorCount
    var isRunning = false

    private var paint: Color {
        switch color {
        case .red:
            return Color(red: 0.93, green: 0.18, blue: 0.25)
        case .blue:
            return Color(red: 0.04, green: 0.43, blue: 0.98)
        case .green:
            return Color(red: 0.08, green: 0.65, blue: 0.36)
        }
    }

    var body: some View {
        Canvas { context, size in
            // Adapta las coordenadas del dibujo al espacio disponible.
            context.scaleBy(
                x: size.width / 320,
                y: size.height / 180
            )

            drawCar(in: &context)
        }
        .aspectRatio(320.0 / 180.0, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Coche \(color.rawValue), \(doors.rawValue) puertas"
        )
        .accessibilityValue(
            isRunning ? "Motor encendido" : "Motor apagado"
        )
    }

    private func drawCar(in context: inout GraphicsContext) {
        let outline = Color(
            red: 0.10,
            green: 0.17,
            blue: 0.29
        )

        // MARK: - Sombra

        context.fill(
            Path(
                ellipseIn: CGRect(
                    x: 32, y: 142,
                    width: 260, height: 16
                )
            ),
            with: .color(.black.opacity(0.10))
        )

        // MARK: - Carrocería

        let body = Path { path in
            path.move(to: CGPoint(x: 26, y: 91))

            path.addQuadCurve(
                to: CGPoint(x: 62, y: 74),
                control: CGPoint(x: 30, y: 76)
            )

            path.addLine(to: CGPoint(x: 89, y: 43))

            path.addQuadCurve(
                to: CGPoint(x: 115, y: 32),
                control: CGPoint(x: 99, y: 32)
            )

            path.addLine(to: CGPoint(x: 193, y: 32))

            path.addQuadCurve(
                to: CGPoint(x: 217, y: 45),
                control: CGPoint(x: 207, y: 32)
            )

            path.addLine(to: CGPoint(x: 247, y: 76))

            path.addQuadCurve(
                to: CGPoint(x: 292, y: 97),
                control: CGPoint(x: 286, y: 78)
            )

            path.addLine(to: CGPoint(x: 296, y: 117))

            path.addQuadCurve(
                to: CGPoint(x: 282, y: 131),
                control: CGPoint(x: 296, y: 131)
            )

            path.addLine(to: CGPoint(x: 38, y: 131))

            path.addQuadCurve(
                to: CGPoint(x: 24, y: 117),
                control: CGPoint(x: 24, y: 131)
            )

            path.closeSubpath()
        }

        context.fill(
            body,
            with: .linearGradient(
                Gradient(
                    colors: [paint, paint.opacity(0.85)]
                ),
                startPoint: CGPoint(x: 160, y: 32),
                endPoint: CGPoint(x: 160, y: 131)
            )
        )

        context.stroke(
            body,
            with: .color(outline.opacity(0.20)),
            lineWidth: 2
        )

        // MARK: - Ventanas

        let windows = Path { path in
            path.move(to: CGPoint(x: 80, y: 74))
            path.addLine(to: CGPoint(x: 102, y: 47))

            path.addQuadCurve(
                to: CGPoint(x: 114, y: 43),
                control: CGPoint(x: 106, y: 43)
            )

            path.addLine(to: CGPoint(x: 190, y: 43))

            path.addQuadCurve(
                to: CGPoint(x: 204, y: 49),
                control: CGPoint(x: 198, y: 43)
            )

            path.addLine(to: CGPoint(x: 228, y: 74))
            path.closeSubpath()
        }

        context.fill(
            windows,
            with: .linearGradient(
                Gradient(
                    colors: [
                        Color(red: 0.73, green: 0.89, blue: 1),
                        outline
                    ]
                ),
                startPoint: CGPoint(x: 160, y: 43),
                endPoint: CGPoint(x: 160, y: 90)
            )
        )

        let windowDivider = Path(
            CGRect(x: 161, y: 42, width: 7, height: 34)
        )

        context.fill(
            windowDivider,
            with: .color(paint)
        )

        // MARK: - Puertas

        let doorOutline = Path { path in
            path.move(to: CGPoint(x: 86, y: 82))
            path.addLine(to: CGPoint(x: 90, y: 111))

            path.addQuadCurve(
                to: CGPoint(x: 99, y: 118),
                control: CGPoint(x: 91, y: 118)
            )

            path.addLine(to: CGPoint(x: 223, y: 118))
            path.addLine(to: CGPoint(x: 230, y: 82))

            if doors == .four {
                path.move(to: CGPoint(x: 165, y: 80))
                path.addLine(to: CGPoint(x: 165, y: 118))
            }
        }

        context.stroke(
            doorOutline,
            with: .color(outline.opacity(0.25)),
            lineWidth: 1.5
        )

        // Solo vemos un lado del coche:
        // una puerta visible equivale a dos en total.
        let handlePositions: [CGFloat] = doors == .four
            ? [140, 205]
            : [205]

        for x in handlePositions {
            context.fill(
                Path(
                    roundedRect: CGRect(
                        x: x, y: 84,
                        width: 15, height: 4
                    ),
                    cornerRadius: 2
                ),
                with: .color(outline.opacity(0.55))
            )
        }

        // MARK: - Luces

        context.fill(
            Path(
                roundedRect: CGRect(
                    x: 26, y: 92,
                    width: 9, height: 15
                ),
                cornerRadius: 3
            ),
            with: .color(
                Color(red: 0.65, green: 0.06, blue: 0.13)
            )
        )

        context.fill(
            Path(
                roundedRect: CGRect(
                    x: 278, y: 91,
                    width: 11, height: 15
                ),
                cornerRadius: 4
            ),
            with: .color(
                isRunning
                    ? .yellow
                    : Color(red: 0.94, green: 0.96, blue: 1)
            )
        )

        // MARK: - Ruedas

        let wheelPositions: [CGFloat] = [77, 244]

        for x in wheelPositions {
            context.fill(
                Path(
                    ellipseIn: CGRect(
                        x: x - 24, y: 104,
                        width: 48, height: 48
                    )
                ),
                with: .color(outline)
            )

            context.fill(
                Path(
                    ellipseIn: CGRect(
                        x: x - 14, y: 114,
                        width: 28, height: 28
                    )
                ),
                with: .color(
                    Color(red: 0.70, green: 0.79, blue: 0.89)
                )
            )

            context.fill(
                Path(
                    ellipseIn: CGRect(
                        x: x - 6, y: 122,
                        width: 12, height: 12
                    )
                ),
                with: .color(.white.opacity(0.65))
            )
        }
    }
}

#Preview("Colores y puertas") {
    VStack(spacing: 16) {
        CarIllustrationView(
            color: .red,
            doors: .two
        )

        CarIllustrationView(
            color: .blue,
            doors: .four,
            isRunning: true
        )

        CarIllustrationView(
            color: .green,
            doors: .four
        )
    }
    .padding(24)
    .background(Color.white)
}
