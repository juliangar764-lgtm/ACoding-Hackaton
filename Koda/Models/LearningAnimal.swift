//
//  LearningAnimal.swift
//  Koda
//
//  Created by ADMIN UNACH on 25/09/26.
//

// Clase base.
class LearningAnimal {
    let name: String

    init(name: String) {
        self.name = name
    }

    func eat() -> String {
        "\(name) está comiendo."
    }

    func sleep() -> String {
        "\(name) está durmiendo."
    }

    func makeSound() -> String {
        "\(name) hace un sonido."
    }
}

// MARK: - Perro

final class LearningDog: LearningAnimal {
    func bark() -> String {
        "\(name) dice: ¡Guau!"
    }

    override func makeSound() -> String {
        bark()
    }
}

// MARK: - Gato

final class LearningCat: LearningAnimal {
    func meow() -> String {
        "\(name) dice: ¡Miau!"
    }

    override func makeSound() -> String {
        meow()
    }
}

// MARK: - Vaca

final class LearningCow: LearningAnimal {
    func moo() -> String {
        "\(name) dice: ¡Muu!"
    }

    override func makeSound() -> String {
        moo()
    }
}
