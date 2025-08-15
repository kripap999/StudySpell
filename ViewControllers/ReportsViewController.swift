import UIKit

class ReportsViewController: UIViewController {
    
    // UI Elements - Connect these through Interface Builder
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var dailyHoursLabel: UILabel!
    @IBOutlet weak var weeklyHoursLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "📊 Reports"
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
        
        // Update scroll view layout
        DispatchQueue.main.async { [weak self] in
            self?.updateScrollViewContentSize()
        }
        
        // Update chart after a small delay to ensure proper layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let weeklyStats = PomodoroSessionManager.shared.getWeeklyStats()
            self.updateChart(with: weeklyStats)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Final scroll view setup after all layouts are complete
        DispatchQueue.main.async { [weak self] in
            self?.finalizeScrollViewSetup()
        }
    }
    
    private func finalizeScrollViewSetup() {
        // Ensure scroll view is working properly
        scrollView.layoutIfNeeded()
        updateScrollViewContentSize()
        
        print("📊 Final Scroll View Status:")
        print("Frame: \(scrollView.frame)")
        print("Content Size: \(scrollView.contentSize)")
        print("Content Inset: \(scrollView.adjustedContentInset)")
        print("Is Scrolling Enabled: \(scrollView.isScrollEnabled)")
    }
    
    private func setupUI() {
        // Set background color to match your app theme
        view.backgroundColor = UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1.0)
        
        // Setup scroll view
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        // Configure content insets for navigation and tab bars
        scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // Setup chart container appearance
        chartContainerView.backgroundColor = UIColor(red: 0.14, green: 0.16, blue: 0.16, alpha: 0.9)
        chartContainerView.layer.cornerRadius = 12
        chartContainerView.layer.borderWidth = 1
        chartContainerView.layer.borderColor = UIColor(red: 0.72, green: 0.51, blue: 0.12, alpha: 0.3).cgColor
    }
    
    
    private func updateStats() {
        // Update streak with proper formatting
        let streak = PomodoroSessionManager.shared.getCurrentStreak()
        streakLabel.text = streak > 0 ? "\(streak) days" : "Start today!"
        
        // Update daily hours
        let todayFocusTime = PomodoroSessionManager.shared.getTotalFocusTimeForDate(Date())
        dailyHoursLabel.text = formatTime(todayFocusTime)
        
        // Update weekly hours
        let weeklyStats = PomodoroSessionManager.shared.getWeeklyStats()
        let weeklyFocusTime = weeklyStats.reduce(0) { $0 + $1.focusTime }
        weeklyHoursLabel.text = formatTime(weeklyFocusTime)
        
        // Only update chart during viewWillAppear, not during layout
        // This prevents constraint conflicts during auto layout
        
        // Add some debug information
        print("📊 Reports Updated:")
        print("Streak: \(streak)")
        print("Today's Focus Time: \(todayFocusTime/60) minutes")
        print("Weekly Focus Time: \(weeklyFocusTime/60) minutes")
        print("Weekly Stats Count: \(weeklyStats.count)")
    }
    
    private func updateChart(with weeklyStats: [(date: Date, sessions: Int, focusTime: TimeInterval)]) {
        // Clear existing chart
        chartContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        guard !weeklyStats.isEmpty else {
            showEmptyChart()
            return
        }
        
        let maxFocusTime = weeklyStats.map { $0.focusTime }.max() ?? 1
        let barWidth: CGFloat = 30
        let barSpacing: CGFloat = 12
        let chartHeight: CGFloat = 80
        let topMargin: CGFloat = 15
        
        let totalWidth = CGFloat(weeklyStats.count) * barWidth + CGFloat(weeklyStats.count - 1) * barSpacing
        let containerWidth = chartContainerView.frame.width > 0 ? chartContainerView.frame.width : 300
        let startX = (containerWidth - totalWidth) / 2
        
        // Add chart title
        let titleLabel = UILabel()
        titleLabel.text = "7-Day Focus History"
        titleLabel.font = UIFont(name: "MagicOwl-PersonalUse", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.72, green: 0.51, blue: 0.12, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 0, y: 5, width: containerWidth, height: 20)
        chartContainerView.addSubview(titleLabel)
        
        // Create bars for each day
        for (index, stat) in weeklyStats.enumerated() {
            let barHeight = maxFocusTime > 0 ? CGFloat(stat.focusTime / maxFocusTime) * chartHeight : 2
            let x = startX + CGFloat(index) * (barWidth + barSpacing)
            let y = chartHeight - barHeight + topMargin + 20
            
            // Bar background (track)
            let barBackground = UIView()
            barBackground.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            barBackground.layer.cornerRadius = 4
            barBackground.frame = CGRect(x: x, y: topMargin + 20, width: barWidth, height: chartHeight)
            chartContainerView.addSubview(barBackground)
            
            // Actual bar
            let bar = UIView()
            let barColor = getBarColor(for: stat.focusTime, max: maxFocusTime)
            bar.backgroundColor = barColor
            bar.layer.cornerRadius = 4
            bar.frame = CGRect(x: x, y: y, width: barWidth, height: max(barHeight, 2))
            chartContainerView.addSubview(bar)
            
            // Day label
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            let dayLabel = UILabel()
            dayLabel.text = dayFormatter.string(from: stat.date)
            dayLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            dayLabel.textColor = UIColor(red: 0.96, green: 0.96, blue: 0.86, alpha: 0.8)
            dayLabel.textAlignment = .center
            dayLabel.frame = CGRect(x: x, y: chartHeight + topMargin + 25, width: barWidth, height: 12)
            chartContainerView.addSubview(dayLabel)
            
            // Add time label if there's focus time
            if stat.focusTime > 0 {
                let timeLabel = UILabel()
                timeLabel.text = formatTimeShort(stat.focusTime)
                timeLabel.font = UIFont.systemFont(ofSize: 8, weight: .bold)
                timeLabel.textColor = UIColor.white
                timeLabel.textAlignment = .center
                timeLabel.frame = CGRect(x: x - 5, y: y - 15, width: barWidth + 10, height: 10)
                chartContainerView.addSubview(timeLabel)
            }
        }
    }
    
    private func showEmptyChart() {
        let emptyLabel = UILabel()
        emptyLabel.text = "Start your first focus session to see your progress!"
        emptyLabel.font = UIFont(name: "MagicOwl-PersonalUse", size: 16) ?? UIFont.systemFont(ofSize: 16)
        emptyLabel.textColor = UIColor(red: 0.72, green: 0.51, blue: 0.12, alpha: 0.7)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.frame = chartContainerView.bounds.insetBy(dx: 20, dy: 20)
        chartContainerView.addSubview(emptyLabel)
    }
    
    private func getBarColor(for focusTime: TimeInterval, max: TimeInterval) -> UIColor {
        let ratio = max > 0 ? focusTime / max : 0
        
        if ratio > 0.7 {
            return UIColor(red: 0.72, green: 0.51, blue: 0.12, alpha: 1.0) // Golden for high
        } else if ratio > 0.4 {
            return UIColor(red: 0.38, green: 0.14, blue: 0.06, alpha: 1.0) // Dark brown for medium
        } else if ratio > 0.1 {
            return UIColor(red: 0.96, green: 0.96, blue: 0.86, alpha: 0.6) // Light cream for low
        } else {
            return UIColor.white.withAlphaComponent(0.2) // Transparent for none
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }
    
    private func formatTimeShort(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update scroll view content size to ensure proper scrolling
        updateScrollViewContentSize()
        
        // Only update chart once the view is properly laid out
        // Prevent multiple updates during constraint resolution
        if chartContainerView.frame.width > 0 && chartContainerView.frame.height > 0 {
            DispatchQueue.main.async { [weak self] in
                self?.updateChart(with: PomodoroSessionManager.shared.getWeeklyStats())
            }
        }
    }
    
    private func updateScrollViewContentSize() {
        // Force layout update to calculate actual content size
        view.layoutIfNeeded()
        scrollView.layoutIfNeeded()
        
        // Let Auto Layout determine the content size based on constraints
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Auto Layout should handle content size, but we can ensure proper scrolling
            // by checking if content extends beyond the visible area
            if let stackView = self.scrollView.subviews.first {
                let contentHeight = stackView.frame.origin.y + stackView.frame.height + 60 // Extra padding
                let visibleHeight = self.scrollView.bounds.height - self.scrollView.adjustedContentInset.top - self.scrollView.adjustedContentInset.bottom
                
                // Ensure content is tall enough to scroll
                let finalContentHeight = max(contentHeight, visibleHeight + 100)
                
                self.scrollView.contentSize = CGSize(
                    width: self.scrollView.bounds.width,
                    height: finalContentHeight
                )
                
                print("📊 Scroll View Layout Updated:")
                print("Visible Height: \(visibleHeight)")
                print("Content Height: \(contentHeight)")
                print("Final Content Size: \(self.scrollView.contentSize)")
                print("Content Insets: \(self.scrollView.adjustedContentInset)")
            }
        }
    }
}

// MARK: - Additional Statistics Methods
extension PomodoroSessionManager {
    func getDetailedStats() -> (todaySessions: Int, totalSessions: Int, totalFocusTime: TimeInterval) {
        let todaySessions = getSessionCount(for: Date())
        let allSessions = getAllSessions()
        let totalSessions = allSessions.values.reduce(0, +)
        let totalFocusTime = getTotalFocusTime()
        
        return (todaySessions, totalSessions, totalFocusTime)
    }
}
