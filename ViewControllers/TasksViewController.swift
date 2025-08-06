//
//  TasksViewController.swift
//  StudySpell
//
//  Created by Kripa Paudel on 29/07/2025.
//
import UIKit
import FSCalendar

class TasksViewController: UIViewController, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegateAppearance {
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var allTasks: [ToDoTask] = []
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        setupTableView()
        setupNavBar()
        loadTasks()
    }
    
    private func setupCalendar() {
        calendar.delegate = self
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2 // Monday
        
        // Style the calendar
        calendar.layer.cornerRadius = 12
        calendar.layer.masksToBounds = true
        calendar.backgroundColor = UIColor(red: 0.14, green: 0.16, blue: 0.16, alpha: 0.98)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        
        // Style the table view
        tableView.layer.cornerRadius = 12
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor(red: 0.14, green: 0.16, blue: 0.16, alpha: 0.98)
        
        // Simple padding
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    private func loadTasks() {
        // Load tasks from UserDefaults - no default tasks
    }
    
    private func fixConstraints() {
        // Ensure Auto Layout is enabled
        calendar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Clear any existing constraints on these views
        calendar.removeFromSuperview()
        tableView.removeFromSuperview()
        titleLabel.removeFromSuperview()
        
        // Re-add to the view hierarchy
        view.addSubview(calendar)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        // Set up clean, simple constraints
        NSLayoutConstraint.activate([
            // Calendar constraints
            calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            calendar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            calendar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            calendar.heightAnchor.constraint(equalToConstant: 300),
            
            // Title Label constraints
            titleLabel.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // TableView constraints
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func setupNavBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc func didTapAdd(){
        performSegue(withIdentifier: "toAddTask", sender: self)
    }
    
    @objc func didTapCheck(_ sender: UIButton) {
        let index = sender.tag
        let task = tasksForSelectedDate()[index]
        
        if let actualIndex = allTasks.firstIndex(where: { $0.dueDate == task.dueDate && $0.title == task.title }) {
            allTasks[actualIndex].isDone.toggle()
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            saveTasks()
        }
    }

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        selectedDate = date
        
        // Add selection animation
        UIView.animate(withDuration: 0.3) {
            self.tableView.reloadData()
        }
        
        // Haptic feedback
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return allTasks.contains(where: {Calendar.current.isDate($0.dueDate, inSameDayAs: date)}) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = tasksForSelectedDate().count
        
        // Show empty state if no tasks
        if count == 0 {
            showEmptyState()
        } else {
            hideEmptyState()
        }
        
        return count
    }
    
    private func showEmptyState() {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        
        let imageView = UIImageView(image: UIImage(systemName: "scroll"))
        imageView.tintColor = UIColor(white: 1.0, alpha: 0.3)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No tasks for today!"
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.addSubview(imageView)
        emptyView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -30),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -20)
        ])
        
        tableView.backgroundView = emptyView
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasksForSelectedDate()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        cell.configure(with: task)
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(didTapCheck(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasksForSelectedDate()[indexPath.row]
        if let i = allTasks.firstIndex(of: task){
            allTasks[i].isDone.toggle()
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            UIView.animate(withDuration: 0.3) {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            saveTasks()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            let task = tasksForSelectedDate()[indexPath.row]
            
            // Show confirmation alert with magical theme
            let alert = UIAlertController(
                title: "Deleting Task",
                message: "Are you sure you want to remove this task?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                // Animate deletion
                UIView.animate(withDuration: 0.3, animations: {
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        cell.alpha = 0
                    }
                }) { _ in
                    self.allTasks.removeAll(where: { $0 == task })
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.calendar.reloadData()
                    self.saveTasks()
                }
            })
            
            present(alert, animated: true)
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveTasks() {
        // Save tasks to UserDefaults for persistence
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(allTasks) {
            UserDefaults.standard.set(encoded, forKey: "SavedTasks")
        }
    }
    
    private func loadTasksFromStorage() {
        if let savedTasks = UserDefaults.standard.object(forKey: "SavedTasks") as? Data {
            let decoder = JSONDecoder()
            if let loadedTasks = try? decoder.decode([ToDoTask].self, from: savedTasks) {
                allTasks = loadedTasks
            }
        }
    }
    
    func tasksForSelectedDate() -> [ToDoTask] {
        return allTasks.filter {
            Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let addVC = segue.destination as? AddTaskViewController {
            addVC.onAddTask = { [weak self] newTask in
                self?.allTasks.append(newTask)
                self?.saveTasks()
                
                // Animate the updates
                UIView.animate(withDuration: 0.3) {
                    self?.calendar.reloadData()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasksFromStorage()
        calendar.select(selectedDate)
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.reloadData()
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        for task in allTasks {
            if Calendar.current.isDate(task.dueDate, inSameDayAs: date) {
                if task.isDone {
                    return UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 0.3) // Green for completed
                } else {
                    return UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 0.3) // Golden for pending
                }
            }
        }
        return nil
    }
}
