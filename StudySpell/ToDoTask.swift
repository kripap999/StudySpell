//
//  ToDoTask.swift
//  StudySpell
//
//  Created by Kripa Paudel on 02/08/2025.
//

import Foundation

struct ToDoTask: Equatable {
    var title: String
    var description: String
    var dueDate: Date
    var isDone: Bool = false
}
