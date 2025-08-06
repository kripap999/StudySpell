//
//  PomodoroSession.swift
//  StudySpell
//
//  Created by Kripa Paudel on 04/08/2025.
//

import Foundation

struct PomodoroSession: Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval // in seconds
    let type: SessionType
    let completedSuccessfully: Bool
    
    init(duration: TimeInterval, type: SessionType, completedSuccessfully: Bool = true) {
        self.id = UUID()
        self.date = Date()
        self.duration = duration
        self.type = type
        self.completedSuccessfully = completedSuccessfully
    }
    
    enum SessionType: String, Codable, CaseIterable {
        case focus = "focus"
        case shortBreak = "short_break"
        case longBreak = "long_break"
        
        var displayName: String {
            switch self {
            case .focus:
                return "Focus Session"
            case .shortBreak:
                return "Short Break"
            case .longBreak:
                return "Long Break"
            }
        }
    }
    
    // Computed properties for display
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

