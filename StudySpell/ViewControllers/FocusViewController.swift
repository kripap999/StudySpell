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
    
    var timer: Timer?
    var isRunning = false
    let defaultFocusSeconds = 30 * 60
    var timeLeft = 30 * 60
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundVideo(named: "focus_background")
        timeLeft = defaultFocusSeconds
        updateTimerLabel()
    }


    //an IBaction function that takes action when the startPauseTapped button is pressed

    //if isRunning is at its default false state, invalidate the timer
    //reset the title to "Start" and the button to its initial defualt state
    //set the boolean isRunning to false
    //else call the startTimer() function
    //reset the title to "Pause" and the button to its initial defualt state
    //set the boolean isRunning to true
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



    //an IBaction function that takes action when the resetTapped button is pressed
    //invalidates the timer
    //resets the total time to its original initial time
    //set isRunning to False
    //reset the title to "Pause" and the button to its initial defualt state
    @IBAction func resetTapped(_ sender: UIButton){
        
        print("Reset tapped")
        timer?.invalidate()
        timer = nil
        timeLeft = defaultFocusSeconds
        
        isRunning = false
        startPauseButton.setTitle("Start", for: .normal)
        updateTimerLabel()
    }



    // startTimer() : a function that starts the clock's timer
    // creating and storing a new Timer object inside timer
    // the closure runs itself everytime the timer is started, with withTimeInterval as 1 second until stopped, and with boolean "repeats" set to false
    //check if the time left is greater than zero as we decrement it by 1 second. keep updating our displayed time with the seconds decremented
    //else invalidate the timer
    //set the boolean isRunning to false
    //reset the title to "Start" and the button to its initial defualt state
    
    @IBOutlet weak var videoContainerView: UIView!

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
            }
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
}
