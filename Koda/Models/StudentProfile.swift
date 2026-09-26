//
//  StudentProfile.swift
//  Koda
//
//  Created by ADMIN UNACH on 21/09/26.
//

import Foundation
import SwiftData

@Model
final class StudentProfile {
    @Attribute(.unique)
    var id: String

    var name: String
    var avatarName: String
    var createdAt: Date
    
    var needsBasicReview: Bool? = nil
    var fundamentalsStep: Int? = nil

    init(name: String, avatarName: String) {
        self.id = "local-student"
        self.name = name
        self.avatarName = avatarName
        self.createdAt = Date()
    }
}
