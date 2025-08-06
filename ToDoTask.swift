//
//  ToDoTask.swift
//  StudySpell
//
//  Created by Kripa Paudel on 02/08/2025.
//

import Foundation

struct ToDoTask: Equatable, Codable {
    var title: String
    var description: String
    var dueDate: Date
    var isDone: Bool = false
    
    // Custom keys for encoding/decoding if needed
    enum CodingKeys: String, CodingKey {
        case title, description, dueDate, isDone
    }
}
