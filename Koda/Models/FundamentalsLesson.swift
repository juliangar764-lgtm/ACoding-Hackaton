//
//  FundamentalsLesson.swift
//  Koda
//
//  Created by ADMIN UNACH on 22/09/26.
//

struct FundamentalsLesson: Identifiable {
    let id: String
    let title: String
    let explanation: String
    let code: String
    let question: String
    let answers: [String]
    let correctAnswer: Int
    let feedback: String

    static let lessons: [Self] = [
        .init(
            id: "variables",
            title: "Variables",
            explanation: """
            Una variable guarda un valor que puede cambiar.
            En Swift usamos var para declararla.
            El tipo indica qué clase de valor contiene,
            como un número o un texto.
            """,
            code: """
            var velocidad = 20
            velocidad = 40
            """,
            question: "¿Qué valor tiene velocidad al final?",
            answers: ["20", "40", "60"],
            correctAnswer: 1,
            feedback: """
            La segunda instrucción reemplaza 20 por 40.
            No suma los dos valores.
            """
        ),
        .init(
            id: "conditions",
            title: "Condiciones",
            explanation: """
            Una condición permite decidir qué instrucciones ejecutar.
            if ejecuta su bloque cuando la condición es verdadera;
            else ofrece una alternativa.
            """,
            code: """
            let semaforo = "rojo"

            if semaforo == "verde" {
                print("Avanza")
            } else {
                print("Espera")
            }
            """,
            question: "¿Qué mensaje aparece?",
            answers: ["Avanza", "Espera", "Ambos mensajes"],
            correctAnswer: 1,
            feedback: """
            El semáforo es rojo. La comparación con verde
            es falsa, así que se ejecuta else.
            """
        ),
        .init(
            id: "loops",
            title: "Bucles",
            explanation: """
            Un bucle repite instrucciones.
            El rango 1...3 incluye los números 1, 2 y 3.
            El guion bajo indica que no necesitamos utilizar
            cada número dentro del bloque.
            """,
            code: """
            for _ in 1...3 {
                print("Hola")
            }
            """,
            question: "¿Cuántas veces aparece Hola?",
            answers: ["Una vez", "Dos veces", "Tres veces"],
            correctAnswer: 2,
            feedback: """
            El bloque se ejecuta una vez por cada número
            del rango: 1, 2 y 3.
            """
        ),
        .init(
            id: "functions",
            title: "Funciones",
            explanation: """
            Una función agrupa instrucciones bajo un nombre.
            Definirla prepara esas instrucciones;
            llamarla hace que se ejecuten.
            """,
            code: """
            func saludar() {
                print("Hola")
            }

            saludar()
            """,
            question: "¿Qué instrucción llama a la función?",
            answers: ["func", "saludar()", "La llave de cierre"],
            correctAnswer: 1,
            feedback: """
            saludar() ejecuta la función.
            func se usa para definirla.
            """
        )
    ]
}
