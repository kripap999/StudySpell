//
//  TasksViewController.swift
//  StudySpell
//
//  Created by Kripa Paudel on 29/07/2025.
//
import UIKit
import FSCalendar

class TasksViewController: UIViewController, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var allTasks: [ToDoTask] = []
    var selectedDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setupNavBar()
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
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        selectedDate = date
        tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return allTasks.contains(where: {Calendar.current.isDate($0.dueDate, inSameDayAs: date)}) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksForSelectedDate().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        let task = tasksForSelectedDate()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.configure(with: task)
        cell.checkButton.tag = indexPath.row
        cell.checkButton.addTarget(self, action: #selector(didTapCheck(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasksForSelectedDate()[indexPath.row]
        if let i = allTasks.firstIndex(of: task){
            allTasks[i].isDone.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            let task = tasksForSelectedDate()[indexPath.row]
            allTasks.removeAll(where: { $0 == task })
            tableView.reloadData()
            calendar.reloadData()
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
                self?.calendar.reloadData()
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendar.select(selectedDate)
        tableView.reloadData()
    }

}
