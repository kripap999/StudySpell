//
//  FocusViewController.swift
//  StudySpell
//
//  Created by Kripa Paudel on 29/07/2025.
//

import UIKit
import AVFoundation

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
        checkForFonts()
        [startPauseButton, resetButton].forEach { button in
            styleButtons(button)
        }
        
        resetButton.isEnabled = false
        startPauseButton.setTitle("Start", for: .normal)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // Ensure labels are in front
        view.bringSubviewToFront(timerLabel)
        view.bringSubviewToFront(startPauseButton)
        view.bringSubviewToFront(resetButton)
    }
    
    func checkForFonts() {
        let harryPotter = UIFont(name: "HarryP", size: 24)
        let magicOwl = UIFont(name: "MagicOwl-PersonalUse", size: 24)
        print("Harry Potter font available: \(harryPotter != nil)")
        print("Magic Owl font available: \(magicOwl != nil)")
    }
    
    @objc private func appDidEnterBackground() {
        backgroundPlayer?.pause()
    }
    
    @objc private func appWillEnterForeground() {
        backgroundPlayer?.play()
    }
    
    private func playBackgroundVideo(named videoName: String) {
        guard let videoPath = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
            print("Video file \(videoName).mp4 not found")
            return
        }
        
        let videoURL = URL(fileURLWithPath: videoPath)
        backgroundPlayer = AVPlayer(url: videoURL)
        
        let playerLayer = AVPlayerLayer(player: backgroundPlayer)
        playerLayer.frame = videoContainerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
        
        backgroundPlayer?.play()
        
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: backgroundPlayer?.currentItem,
            queue: .main
        ) { _ in
            self.backgroundPlayer?.seek(to: CMTime.zero)
            self.backgroundPlayer?.play()
        }
    }
    
    @IBAction func startPauseButtonTapped(_ sender: UIButton) {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resetTimer()
    }
    
    private func startTimer() {
        isRunning = true
        resetButton.isEnabled = true
        startPauseButton.setTitle("Pause", for: .normal)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeLeft -= 1
            self.updateTimerLabel()
            
            if self.timeLeft <= 0 {
                self.timerCompleted()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        startPauseButton.setTitle("Start", for: .normal)
    }
    
    private func resetTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        timeLeft = defaultFocusSeconds
        isBreakMode = false
        updateTimerLabel()
        resetButton.isEnabled = false
        startPauseButton.setTitle("Start", for: .normal)
    }
    
    private func updateTimerLabel() {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func timerCompleted() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        resetButton.isEnabled = false
        startPauseButton.setTitle("Start", for: .normal)
        
        if !isBreakMode {
            // Focus session completed, start break
            showBreakSession()
        } else {
            // Break completed, ready for next focus session
            isBreakMode = false
            timeLeft = defaultFocusSeconds
            updateTimerLabel()
            showAlert(title: "Break Complete!", message: "Ready for another focus session?")
        }
    }
    
    private func showBreakSession() {
        isBreakMode = true
        timeLeft = 5 * 60 // 5 minute break
        updateTimerLabel()
        
        // Get break content from the service
        BreakSuggestionService.shared.getBreakContent { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let content):
                    self?.showBreakAlert(with: content)
                case .failure(let error):
                    print("Failed to get break content: \(error)")
                    self?.showDefaultBreakAlert()
                }
            }
        }
    }
    
    private func showBreakAlert(with content: BreakContent) {
        let alert = UIAlertController(
            title: "🎉 Focus Session Complete!",
            message: """
            Great job! Time for a break.
            
            💡 \(content.suggestion)
            
            📚 \(content.quote)
            
            🌟 \(content.funFact)
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Start Break", style: .default) { _ in
            self.startTimer()
        })
        
        alert.addAction(UIAlertAction(title: "Skip Break", style: .cancel) { _ in
            self.isBreakMode = false
            self.timeLeft = self.defaultFocusSeconds
            self.updateTimerLabel()
        })
        
        present(alert, animated: true)
    }
    
    private func showDefaultBreakAlert() {
        let alert = UIAlertController(
            title: "🎉 Focus Session Complete!",
            message: """
            Great job! Time for a 5-minute break.
            
            💡 Take a moment to stretch and relax
            📚 "Success is not final, failure is not fatal: it is the courage to continue that counts." - Winston Churchill
            🌟 Taking breaks helps improve your focus and productivity!
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Start Break", style: .default) { _ in
            self.startTimer()
        })
        
        alert.addAction(UIAlertAction(title: "Skip Break", style: .cancel) { _ in
            self.isBreakMode = false
            self.timeLeft = self.defaultFocusSeconds
            self.updateTimerLabel()
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func styleButtons(_ button: UIButton?) {
        guard let button = button else { return }
        
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        backgroundPlayer?.pause()
        backgroundPlayer = nil
    }
}
