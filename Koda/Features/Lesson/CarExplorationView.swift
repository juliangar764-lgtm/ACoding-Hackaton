import SwiftUI

@MainActor
struct CarExplorationView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var myCar = LearningCar(
        color: .red,
        doors: .two
    )

    @State private var anasCar = LearningCar(
        color: .blue,
        doors: .four
    )

    private let onExampleStateChange: (String) -> Void

    init(
        onExampleStateChange: @escaping (String) -> Void = { _ in }
    ) {
        self.onExampleStateChange = onExampleStateChange
    }

    // MARK: - Distribución adaptable

    private var adaptiveLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(
                VStackLayout(
                    alignment: .leading,
                    spacing: 12
                )
            )
            : AnyLayout(
                HStackLayout(spacing: 12)
            )
    }

    // MARK: - Código visible

    private var exampleCode: String {
        """
        miCoche.color = "\(myCar.color.rawValue)"
        miCoche.puertas = \(myCar.doors.rawValue)
        """
    }

    // MARK: - Estado para el profesor

    private var currentExampleState: String {
        """
        Ejemplo visible: dos objetos distintos de la clase Coche.

        miCoche:
        - color: \(myCar.color.rawValue)
        - puertas: \(myCar.doors.rawValue)
        - enMarcha: \(myCar.isRunning ? "true" : "false")

        cocheDeAna:
        - color: \(anasCar.color.rawValue)
        - puertas: \(anasCar.doors.rawValue)
        - enMarcha: \(anasCar.isRunning ? "true" : "false")

        Los controles de esta pantalla modifican solamente miCoche.
        Estos datos describen el estado actual, no el historial de acciones.
        """
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 8) {
                Text("miCoche")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)

                CarIllustrationView(
                    color: myCar.color,
                    doors: myCar.doors,
                    isRunning: myCar.isRunning
                )
                .frame(maxWidth: 360)

                Label(
                    myCar.isRunning ? "Arrancado" : "Detenido",
                    systemImage: myCar.isRunning
                        ? "play.fill"
                        : "stop.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(
                    myCar.isRunning
                        ? KodaPalette.green
                        : KodaPalette.secondary
                )
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .kodaPanel(fill: KodaPalette.paleBlue)

            colorControls
            doorControls

            KodaCodeCard(code: exampleCode)

            actionControls
            comparison

            KodaTeacherMessage(
                message: """
                Los dos objetos se crearon con la misma clase. \
                Cambiar miCoche no cambia los valores de cocheDeAna.
                """
            )
        }
        .foregroundStyle(KodaPalette.ink)
        .onChange(
            of: currentExampleState,
            initial: true
        ) { _, newState in
            onExampleStateChange(newState)
        }
    }

    // MARK: - Color

    private var colorControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Color")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            adaptiveLayout {
                ForEach(LearningCar.PaintColor.allCases) { color in
                    selectionButton(
                        title: color.title,
                        isSelected: myCar.color == color
                    ) {
                        myCar.color = color
                    }
                    .accessibilityLabel(
                        "Color \(color.rawValue)"
                    )
                }
            }
        }
    }

    // MARK: - Puertas

    private var doorControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Número de puertas")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            adaptiveLayout {
                ForEach(LearningCar.DoorCount.allCases) { doors in
                    selectionButton(
                        title: "\(doors.rawValue) puertas",
                        isSelected: myCar.doors == doors
                    ) {
                        myCar.doors = doors
                    }
                }
            }
        }
    }

    private func selectionButton(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Image(
                    systemName: isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .accessibilityHidden(true)
            }
            .foregroundStyle(
                isSelected
                    ? KodaPalette.blue
                    : KodaPalette.ink
            )
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(10)
            .kodaPanel(
                fill: isSelected
                    ? KodaPalette.paleBlue
                    : .white,
                border: isSelected
                    ? KodaPalette.blue
                    : KodaPalette.line
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 20)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(
            isSelected ? .isSelected : []
        )
    }

    // MARK: - Acciones del coche

    private var actionControls: some View {
        adaptiveLayout {
            Button {
                myCar.start()
            } label: {
                Label(
                    "Arrancar",
                    systemImage: "play.fill"
                )
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .tint(KodaPalette.green)
            .disabled(myCar.isRunning)

            Button {
                myCar.stop()
            } label: {
                Label(
                    "Frenar",
                    systemImage: "stop.fill"
                )
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .tint(.red)
            .disabled(!myCar.isRunning)
        }
        .buttonStyle(.bordered)
    }

    // MARK: - Segundo objeto

    private var comparison: some View {
        adaptiveLayout {
            CarIllustrationView(
                color: anasCar.color,
                doors: anasCar.doors,
                isRunning: anasCar.isRunning
            )
            .frame(width: 112)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text("cocheDeAna")
                    .font(.headline)

                Text(
                    "\(anasCar.color.title) · \(anasCar.doors.rawValue) puertas"
                )
                .font(.subheadline)

                Text("Conserva sus propios valores.")
                    .font(.subheadline)
            }
            .foregroundStyle(KodaPalette.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .kodaPanel()
        .accessibilityElement(children: .combine)
    }
}

#Preview("Explorar un objeto") {
    ScrollView {
        CarExplorationView()
            .padding(20)
    }
    .kodaScreen()
    .preferredColorScheme(.light)
}
