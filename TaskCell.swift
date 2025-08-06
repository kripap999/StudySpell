//
//  TaskCell.swift
//  StudySpell
//
//  Created by Kripa Paudel on 03/08/2025.
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var onToggle: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        
        layer.cornerRadius = 12
        
    }
    
    func configure(with task: ToDoTask) {
        titleLabel.text = task.title
        descLabel.text = task.description.isEmpty ? "" : task.description
        
        let imageName = task.isDone ? "checkmark.circle.fill" : "circle"
        checkButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        // Update appearance based on completion status
        if task.isDone {
            titleLabel.alpha = 0.6
            descLabel.alpha = 0.6
            titleLabel.attributedText = NSAttributedString(
                string: task.title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
        } else {
            titleLabel.alpha = 1.0
            descLabel.alpha = 1.0
            titleLabel.attributedText = NSAttributedString(string: task.title)
            backgroundColor = UIColor.systemBackground
        }
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        // Simple button animation
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
            }
        }
        
        onToggle?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        backgroundColor = UIColor.systemBackground
        alpha = 1.0
    }
}
