//
//  TaskCell.swift
//  StudySpell
//
//  Created by Kripa Paudel on 03/08/2025.
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
   
        var onToggle: (() -> Void)?  // Optional closure to notify toggle action
        
        
        func configure(with task: ToDoTask) {
            titleLabel.text = task.title
            let imageName = task.isDone ? "checkmark.circle.fill" : "circle"
            checkButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
        
        @IBAction func checkButtonTapped(_ sender: UIButton) {
            onToggle?()
        }
    }
