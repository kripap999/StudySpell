import Foundation

class PomodoroSessionManager {
    static let shared = PomodoroSessionManager()
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "pomodoro_sessions"
    private let detailedSessionsKey = "detailed_pomodoro_sessions"
    
    private init() {}
    
    // MARK: - Session Management
    
    // Save a completed session with details
    func saveSession(_ session: PomodoroSession) {
        // Update simple count for backward compatibility
        saveSimpleSession()
        
        // Save detailed session
        saveDetailedSession(session)
    }
    
    // Save a completed focus session (convenience method)
    func saveFocusSession(duration: TimeInterval, completed: Bool = true) {
        let session = PomodoroSession(duration: duration, type: .focus, completedSuccessfully: completed)
        saveSession(session)
    }
    
    // Save a break session
    func saveBreakSession(duration: TimeInterval, type: PomodoroSession.SessionType) {
        let session = PomodoroSession(duration: duration, type: type, completedSuccessfully: true)
        saveSession(session)
    }
    
    // MARK: - Simple Session Count (for backward compatibility)
    
    private func saveSimpleSession() {
        let today = getTodayDateString()
        var sessions = userDefaults.dictionary(forKey: sessionsKey) as? [String: Int] ?? [:]
        sessions[today, default: 0] += 1
        userDefaults.set(sessions, forKey: sessionsKey)
    }
    
    // Get session count for a specific date
    func getSessionCount(for date: Date) -> Int {
        let key = formatDate(date)
        let sessions = userDefaults.dictionary(forKey: sessionsKey) as? [String: Int] ?? [:]
        return sessions[key, default: 0]
    }
    
    // Get all session counts
    func getAllSessions() -> [String: Int] {
        return userDefaults.dictionary(forKey: sessionsKey) as? [String: Int] ?? [:]
    }
    
    // MARK: - Detailed Session Management
    
    private func saveDetailedSession(_ session: PomodoroSession) {
        var sessions = getDetailedSessions()
        sessions.append(session)
        
        // Keep only last 100 sessions to prevent data bloat
        if sessions.count > 100 {
            sessions = Array(sessions.suffix(100))
        }
        
        if let data = try? JSONEncoder().encode(sessions) {
            userDefaults.set(data, forKey: detailedSessionsKey)
        }
    }
    
    func getDetailedSessions() -> [PomodoroSession] {
        guard let data = userDefaults.data(forKey: detailedSessionsKey),
              let sessions = try? JSONDecoder().decode([PomodoroSession].self, from: data) else {
            return []
        }
        return sessions
    }
    
    func getSessionsForDate(_ date: Date) -> [PomodoroSession] {
        let calendar = Calendar.current
        return getDetailedSessions().filter { session in
            calendar.isDate(session.date, inSameDayAs: date)
        }
    }
    
    func getFocusSessionsForDate(_ date: Date) -> [PomodoroSession] {
        return getSessionsForDate(date).filter { $0.type == .focus }
    }
    
    func getBreakSessionsForDate(_ date: Date) -> [PomodoroSession] {
        return getSessionsForDate(date).filter { $0.type == .shortBreak || $0.type == .longBreak }
    }
    
    func getTotalBreakTime() -> TimeInterval {
        return getDetailedSessions()
            .filter { ($0.type == .shortBreak || $0.type == .longBreak) && $0.completedSuccessfully }
            .reduce(0) { $0 + $1.duration }
    }
    
    func getTotalBreakTimeForDate(_ date: Date) -> TimeInterval {
        return getBreakSessionsForDate(date)
            .filter { $0.completedSuccessfully }
            .reduce(0) { $0 + $1.duration }
    }
    
    // MARK: - Statistics
    
    func getTotalFocusTime() -> TimeInterval {
        return getDetailedSessions()
            .filter { $0.type == .focus && $0.completedSuccessfully }
            .reduce(0) { $0 + $1.duration }
    }
    
    func getTotalFocusTimeForDate(_ date: Date) -> TimeInterval {
        return getFocusSessionsForDate(date)
            .filter { $0.completedSuccessfully }
            .reduce(0) { $0 + $1.duration }
    }
    
    func getAverageSessionDuration() -> TimeInterval {
        let focusSessions = getDetailedSessions().filter { $0.type == .focus && $0.completedSuccessfully }
        guard !focusSessions.isEmpty else { return 0 }
        
        let totalDuration = focusSessions.reduce(0) { $0 + $1.duration }
        return totalDuration / Double(focusSessions.count)
    }
    
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        // Check if today has sessions
        if getSessionCount(for: currentDate) > 0 {
            streak = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        // Count consecutive days with sessions going backwards
        while getSessionCount(for: currentDate) > 0 {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    func getWeeklyStats() -> [(date: Date, sessions: Int, focusTime: TimeInterval)] {
        let calendar = Calendar.current
        let today = Date()
        var weekStats: [(date: Date, sessions: Int, focusTime: TimeInterval)] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let sessionCount = getSessionCount(for: date)
            let focusTime = getTotalFocusTimeForDate(date)
            weekStats.append((date: date, sessions: sessionCount, focusTime: focusTime))
        }
        
        return weekStats.reversed() // Show oldest to newest
    }
    
    // MARK: - Utility Methods
    
    private func getTodayDateString() -> String {
        return formatDate(Date())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        userDefaults.removeObject(forKey: sessionsKey)
        userDefaults.removeObject(forKey: detailedSessionsKey)
    }
    
    func exportData() -> [String: Any] {
        return [
            "sessions": getAllSessions(),
            "detailedSessions": getDetailedSessions().compactMap { session in
                try? JSONEncoder().encode(session)
            }.compactMap { data in
                try? JSONSerialization.jsonObject(with: data)
            }
        ]
    }
}
