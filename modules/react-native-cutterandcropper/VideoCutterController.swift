//
//  VideoCutterController.swift
//  DoubleConversion
//
//  Created by Nika Samadashvili on Jan/28/20.
//

import UIKit
import AVFoundation



class VideoCutterController : UIViewController {
    
    private let trimmerView = TrimmerView()
    private var player: AVPlayer?
    var url : URL!
    
    private var playerView: UIView = {
        let playerView = UIView(frame: .zero)
        return playerView
    }()
    
    private let topBar : UIView = {
        let topBar = UIView(frame: .zero)
        topBar.backgroundColor = .white
        return topBar
    }()
    
    private let backButton : UIButton = {
        let backButton = UIButton(frame: .zero)
        backButton.setImage(#imageLiteral(resourceName: "backIcon"), for: .normal)
        return backButton
    }()
    
    private let nextButton : UIButton = {
        let backButton = UIButton(frame: .zero)
        backButton.setTitle("Next", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        return backButton
    }()
    
    
    private let titleLabel : UILabel = {
        let title = UILabel(frame: .zero)
        title.text = "Cutter"
        return title
    }()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        self.view.backgroundColor = .white
        trimmerView.delegate = self
        trimmerView.mainColor = UIColor(red: 0.273, green: 0.471, blue: 0.995, alpha: 1.0)
        trimmerView.handleColor = .white
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.2) {
            self.trimmerView.asset = AVAsset(url: self.url)
            self.addVideoPlayer(with: AVAsset(url: self.url!), playerView: self.playerView)
            self.topBar.dropShadow()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout()
    }
    
    
    private func layout(){
        self.view.addSubview(trimmerView)
        self.view.addSubview(playerView)
        self.view.addSubview(topBar)
        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(nextButton)
        
        self.topBar.translatesAutoresizingMaskIntoConstraints = false
        self.topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.topBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if #available(iOS 11.0, *) {
            self.topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            self.topBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        self.backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        self.backButton.leftAnchor.constraint(equalTo: topBar.leftAnchor, constant: 15).isActive = true
        self.backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        self.nextButton.rightAnchor.constraint(equalTo: topBar.rightAnchor, constant: -15).isActive = true
        self.nextButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.nextButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor).isActive = true
        self.titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor).isActive = true

        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        self.playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.playerView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        self.playerView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        
        self.trimmerView.translatesAutoresizingMaskIntoConstraints = false
        self.trimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.trimmerView.topAnchor.constraint(equalTo: self.playerView.bottomAnchor, constant: 70).isActive = true
        self.trimmerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
        }
    }
    
}

extension VideoCutterController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        //startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        //stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        
        print(duration)
    }
}

 extension UIView {
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

    }
}
