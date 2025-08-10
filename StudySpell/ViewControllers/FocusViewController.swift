//
//  FocusViewController.swift
//  StudySpell
//
//  Created by Kripa Paudel on 29/07/2025.
//

import UIKit
import AVFoundation

// MARK: - Break Content Models
struct QuoteResponse: Codable {
    let quote: String
    let author: String
}

struct AdviceResponse: Codable {
    let slip: AdviceSlip
}

struct AdviceSlip: Codable {
    let id: Int
    let advice: String
}

struct CatFactResponse: Codable {
    let fact: String
}

struct BreakContent {
    let suggestion: String
    let quote: String
    let funFact: String
}

// MARK: - Break Suggestion Service
class BreakSuggestionService {
    static let shared = BreakSuggestionService()
    
    private init() {}
    
    private let breakSuggestions = [
        "Take a 5-minute walk to refresh your mind",
        "Drink a glass of water to stay hydrated",
        "Do some deep breathing exercises",
        "Look away from screens and focus on something distant",
        "Do some light stretching exercises",
        "Listen to your favorite song",
        "Water your plants or step outside for fresh air",
        "Make yourself a warm drink",
        "Send a quick message to a friend or family member",
        "Do a quick brain teaser or puzzle"
    ]
    
    func getRandomBreakSuggestion() -> String {
        return breakSuggestions.randomElement() ?? "Take a short break and relax!"
    }
    
    private let fallbackQuotes = [
        "\"The only way to do great work is to love what you do.\" - Steve Jobs",
        "\"Success is not final, failure is not fatal: it is the courage to continue that counts.\" - Winston Churchill",
        "\"The future belongs to those who believe in the beauty of their dreams.\" - Eleanor Roosevelt",
        "\"It is during our darkest moments that we must focus to see the light.\" - Aristotle",
        "\"Believe you can and you're halfway there.\" - Theodore Roosevelt",
        "\"The only impossible journey is the one you never begin.\" - Tony Robbins",
        "\"In the middle of difficulty lies opportunity.\" - Albert Einstein",
        "\"Success is not how high you have climbed, but how you make a positive difference to the world.\" - Roy T. Bennett"
    ]
    
    func getRandomFallbackQuote() -> String {
        return fallbackQuotes.randomElement() ?? "\"Believe in yourself!\" - StudySpell"
    }
    
    func fetchBreakContent(completion: @escaping (Result<BreakContent, Error>) -> Void) {
        let group = DispatchGroup()
        
        var motivationalQuote = "\"Believe in yourself!\" - StudySpell"
        var funFact = "Did you know? Taking breaks improves focus and productivity!"
        let breakSuggestion = getRandomBreakSuggestion()
        
        // Fetch motivational quote
        group.enter()
        fetchMotivationalQuote { result in
            switch result {
            case .success(let quote):
                motivationalQuote = quote
            case .failure:
                motivationalQuote = self.getRandomFallbackQuote()
            }
            group.leave()
        }
        
        // Fetch fun fact
        group.enter()
        fetchRandomFunFact { result in
            switch result {
            case .success(let fact):
                funFact = fact
            case .failure:
                funFact = "You're building great study habits! Keep going!"
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            let content = BreakContent(
                suggestion: breakSuggestion,
                quote: motivationalQuote,
                funFact: funFact
            )
            completion(.success(content))
        }
    }
    
    private func fetchMotivationalQuote(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://zenquotes.io/api/random") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                // ZenQuotes returns an array with one quote object
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   let firstQuote = jsonArray.first,
                   let text = firstQuote["q"] as? String,
                   let author = firstQuote["a"] as? String {
                    let formattedQuote = "\"\(text)\" - \(author)"
                    completion(.success(formattedQuote))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON format", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func fetchRandomFunFact(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://cat-fact.herokuapp.com/facts/random") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let factData = try JSONDecoder().decode(CatFactResponse.self, from: data)
                completion(.success("Fun Fact: \(factData.fact)"))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

class FocusViewController: UIViewController{
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var videoContainerView: UIView!
    
    var timer: Timer?
    var isRunning = false
    let defaultFocusSeconds = 5 * 60
    var timeLeft = 5 * 60
    var isBreakMode = false
    
    var backgroundPlayer: AVPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundVideo(named: "focus_background")
        timeLeft = defaultFocusSeconds
        updateTimerLabel()
    }
    
    // MARK: - Video Background Methods
    @IBAction func startPauseTapped(_ sender: UIButton) {
        if isRunning {
            timer?.invalidate()
            startPauseButton.setTitle("Start", for: .normal)
            isRunning = false
        }else{
            startTimer()
            startPauseButton.setTitle("Pause", for: .normal)
            isRunning = true
        }
    }

    func timerDidFinish() {
        timer?.invalidate()
        isRunning = false
        
        // Calculate the session duration (original time - time left)
        let sessionDuration = TimeInterval(defaultFocusSeconds - timeLeft)
        
        // Save the focus session with duration
        PomodoroSessionManager.shared.saveFocusSession(
            duration: sessionDuration,
            completed: timeLeft == 0 // true if timer completed, false if stopped early
        )
        
        timeLeft = defaultFocusSeconds

        print("Session completed and saved! Duration: \(sessionDuration/60) minutes")
        
        // Show completion alert with motivational message
        showSessionCompletedAlert()
    }


    //an IBaction function that takes action when the resetTapped button is pressed
    //invalidates the timer
    //resets the total time to its original initial time
    //set isRunning to False
    //reset the title to "Pause" and the button to its initial defualt state
    @IBAction func resetTapped(_ sender: UIButton){
        
        print("Reset tapped")
        
        // If timer was running, save partial session (only for focus sessions)
        if isRunning && !isBreakMode && timeLeft < defaultFocusSeconds {
            let sessionDuration = TimeInterval(defaultFocusSeconds - timeLeft)
            if sessionDuration > 60 { // Only save if more than 1 minute was completed
                PomodoroSessionManager.shared.saveFocusSession(
                    duration: sessionDuration,
                    completed: false
                )
                print("Partial session saved: \(sessionDuration/60) minutes")
            }
        }
        
        timer?.invalidate()
        timer = nil
        timeLeft = defaultFocusSeconds
        isBreakMode = false
        
        isRunning = false
        startPauseButton.setTitle("Start", for: .normal)
        startPauseButton.isEnabled = true
        updateUIForMode()
        updateTimerLabel()
    }



    // startTimer() : a function that starts the clock's timer
    // creating and storing a new Timer object inside timer
    // the closure runs itself everytime the timer is started, with withTimeInterval as 1 second until stopped, and with boolean "repeats" set to false
    //check if the time left is greater than zero as we decrement it by 1 second. keep updating our displayed time with the seconds decremented
    //else invalidate the timer
    //set the boolean isRunning to false
    //reset the title to "Start" and the button to its initial defualt state

    func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ _ in
            if self.timeLeft > 0{
                self.timeLeft -= 1
                self.updateTimerLabel()
            }else{
                self.timer?.invalidate()
                self.timer = nil
                self.isRunning = false
                self.startPauseButton.setTitle("Start", for: .normal)
                self.timerDidFinish()
            }
        }
        if timeLeft <= 0 {
            timerDidFinish()
        }

        RunLoop.main.add(timer!, forMode: .common)
    }


    // updateTimerLabel(): updates the text on the timer label with the updated time
    //set minutes as timeLeft/60 to display the number of minutes
    //set seconds as timeLeft % 60 to display the number of seconds
    //set the format of the display and assign the string to timerLabel text

    func updateTimerLabel(){
    let minutes = timeLeft / 60
    let seconds = timeLeft % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
   }
    
    private func updateUIForMode() {
        if isBreakMode {
            title = "Break Time"
            timerLabel.textColor = UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0) // Slytherin green
            view.backgroundColor = .systemBackground
        } else {
            title = "Focus Time"
            timerLabel.textColor = UIColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1.0) // Golden color
            view.backgroundColor = .systemBackground
        }
    }

    //an IBaction function that takes action when the startPauseTapped button is pressed

    //if isRunning is at its default false state, invalidate the timer
    //reset the title to "Start" and the button to its initial defualt state
    //set the boolean isRunning to false
    //else call the startTimer() function
    //reset the title to "Pause" and the button to its initial defualt state
    //set the boolean isRunning to true
    @IBAction func startPauseTapped(_ sender: UIButton) {
   }
    
    // MARK: - Video Background Methods
    
//  initialize a var that holds AVPlayer instance. it is implicitly unwrapped optional(might be nill initially but will be set before used
//  declare a function that takes fileName string and plays the corresponding video file
//  find the path of the video; if not found, return a message
    var backgroundPlayer: AVPlayer?
    func playBackgroundVideo(named fileName: String){
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp4") else {
            print("Video not found")
            return
        }
        
//  Create an AVPlayer instance: You typically initialize an AVPlayer with an AVPlayerItem, which represents the media asset to be played. The AVPlayerItem in turn is initialized with an AVAsset or a URL.
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        backgroundPlayer = AVPlayer(playerItem: playerItem)
        
//  Display the video (for video content)
//  If playing video, use AVPlayerViewController from AVKit or use AVPlayerLayer for custom UI.
        
        let playerLayer = AVPlayerLayer(player: backgroundPlayer)
        playerLayer.frame = videoContainerView.bounds
        playerLayer.videoGravity = .resizeAspect
        
      
        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
        
        NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { _ in
                self.backgroundPlayer?.seek(to: .zero)
                self.backgroundPlayer?.play()
            }
        
        
        
        backgroundPlayer?.play()
        
        
    }
    
    // MARK: - Session Management
    
    private func showSessionCompletedAlert() {
        let currentStreak = PomodoroSessionManager.shared.getCurrentStreak()
        
        let title = "Focus Session Complete!"
        var message = "Well done! You've completed another study session."
        
        // Add streak information
        if currentStreak > 1 {
            message += "\n\n You're on a \(currentStreak)-day streak!"
        }
        
        // Show loading state while fetching break content
        let alert = UIAlertController(title: title, message: message + "\n\nFetching your break suggestions...", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue Studying", style: .cancel) { _ in
            // Reset timer for another session
            self.timeLeft = self.defaultFocusSeconds
            self.updateTimerLabel()
        })
        
        present(alert, animated: true) {
            // Fetch break content from APIs
            BreakSuggestionService.shared.fetchBreakContent { [weak self] result in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        self?.showBreakScreen(result: result, streak: currentStreak)
                    }
                }
            }
        }
    }
    
    private func showBreakScreen(result: Result<BreakContent, Error>, streak: Int) {
        let title = "Time for a Break!"
        var message = ""
        
        switch result {
        case .success(let content):
            message = """
            \(content.suggestion)
            
            Motivation:
            \(content.quote)
            
            \(content.funFact)
            """
            
        case .failure:
            // Fallback to local content
            let suggestion = BreakSuggestionService.shared.getRandomBreakSuggestion()
            let quote = BreakSuggestionService.shared.getRandomFallbackQuote()
            
            message = """
            \(suggestion)
            
            Motivation:
            \(quote)
            
            You're building great study habits! Keep going!
            """
        }
        
        if streak > 1 {
            message += "\n\nYou're on a \(streak)-day streak!"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Start Break Timer Action
        alert.addAction(UIAlertAction(title: "Start 5-min Break", style: .default) { _ in
            self.startBreakTimer()
        })
        
        // Skip Break Action
        alert.addAction(UIAlertAction(title: "Continue Studying", style: .default) { _ in
            self.timeLeft = self.defaultFocusSeconds
            self.updateTimerLabel()
        })
        
        // View Reports Action
        alert.addAction(UIAlertAction(title: "View Progress", style: .cancel) { _ in
            self.tabBarController?.selectedIndex = 1 // Assuming Reports is at index 1
        })
        
        present(alert, animated: true)
    }
    
    private func startBreakTimer() {
        let breakDuration = 5 * 60 // 5 minutes
        timeLeft = breakDuration
        isBreakMode = true
        updateUIForMode()
        updateTimerLabel()
        
        // Stop ambient audio during break
        
        // Update UI to show break mode
        startPauseButton.setTitle("Break in Progress", for: .normal)
        startPauseButton.isEnabled = false
        
        // Start break timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeLeft > 0 {
                self.timeLeft -= 1
                self.updateTimerLabel()
            } else {
                self.breakTimerFinished()
            }
        }
        
        isRunning = true
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func breakTimerFinished() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isBreakMode = false
        
        // Save break session
        PomodoroSessionManager.shared.saveBreakSession(duration: 5 * 60, type: .shortBreak)
        
        // Reset to focus mode
        timeLeft = defaultFocusSeconds
        updateUIForMode()
        updateTimerLabel()
        startPauseButton.setTitle("Start", for: .normal)
        startPauseButton.isEnabled = true
        
        // Show break completion alert
        let alert = UIAlertController(
            title: "Break Complete!",
            message: "Ready to focus again?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Start Focus Session", style: .default) { _ in
            self.startTimer()
            self.startPauseButton.setTitle("Pause", for: .normal)
            self.isRunning = true
        })
        
        alert.addAction(UIAlertAction(title: "Not Yet", style: .cancel))
        
        present(alert, animated: true)
    }
}
