//
//  AddTaskViewController.swift
//  StudySpell
//
//  Created by Kripa Paudel on 02/08/2025.
//

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var onAddTask: ((ToDoTask) -> Void)?

    
    @IBAction func donePressed(_ sender: Any) {
        let newTask = ToDoTask(
            title: nameField.text ?? "",
            description: descField.text ?? "",
            dueDate: datePicker.date
        )
        onAddTask?(newTask)
        navigationController?.popViewController(animated: true)
    }
}
