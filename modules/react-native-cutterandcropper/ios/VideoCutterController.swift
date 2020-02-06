//
//  VideoCutterController.swift
//  react-native-cutterandcropper
//
//  Created by Nika Samadashvili on Feb/4/20.
//


import UIKit
import AVFoundation

protocol VideoCutterDelegate : class {
    func didCancelController()
    func didfinishWith(data:[String:Any])
    func didfinishWith(error:[String:Error])
}


final class VideoCutterController : UIViewController {
    weak var delegate : VideoCutterDelegate?
    
    private var playbackTimeCheckerTimer: Timer?
    
    var assetURL : String!
    var videoMaxDuration : Double = 90
    
    private let themeColor = UIColor(red: 0.273, green: 0.471, blue: 0.995, alpha: 1.0)
    private var player: AVPlayer?
    private let trimmerView = TrimmerView()
    private let videoTrimmer = VideoTrimmer()
    private var randomInt = Int.random(in: 0...1000000)
    private var thumbnailImageUri : String!
    private var thumbNailImageCompressionQuality : CGFloat = 0.6
    
    private var leftMaskView: UIView = {
        let leftMaskView = UIView(frame: .zero)
        leftMaskView.backgroundColor = .white
        leftMaskView.alpha = 0.7
        return leftMaskView
    }()
    
    private var rightMaskView: UIView = {
        let rightMaskView = UIView(frame: .zero)
        rightMaskView.backgroundColor = .white
        rightMaskView.alpha = 0.7
        return rightMaskView
    }()
    
    private var playerView: UIView = {
        let playerView = UIView(frame: .zero)
        return playerView
    }()
    
    private let topBar : UIView = {
        let topBar = UIView(frame: .zero)
        topBar.backgroundColor = .white
        return topBar
    }()
    
    //    private var resetBtn : UIView = {
    //        let resetBtn = UIButton(type: UIButton.ButtonType.system)
    //        resetBtn.backgroundColor = themeColor
    //
    //        return resetBtn
    //    }()
    
    private let backButton : UIButton = {
        let backButton = UIButton(type: UIButton.ButtonType.system)
        backButton.setImage(#imageLiteral(resourceName: "backIcon"), for: .normal)
        backButton.tintColor = .black
        return backButton
    }()
    
    private let nextButton : UIButton = {
        let nextButton = UIButton(type: UIButton.ButtonType.system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.tintColor = .black
        return nextButton
    }()
    
    
    private let titleLabel : UILabel = {
        let title = UILabel(frame: .zero)
        title.text = "Cutter"
        title.textColor = .black
        return title
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        trimmerView.delegate = self
        trimmerView.mainColor = themeColor
        trimmerView.handleColor = .white
        trimmerView.maxDuration = videoMaxDuration
        nextButton.addTarget(self,action: #selector(didTapNextBtn),for: .touchUpInside)
        backButton.addTarget(self,action: #selector(didTapBackBtn),for: .touchUpInside)
        
    }
    
    deinit{
        print("vasha")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layout()
        
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.3) {[weak self] in
            if let self = self, let assetURL = self.assetURL,let url = URL(string: assetURL) {
                self.trimmerView.asset = AVAsset(url: url)
                self.addVideoPlayer(with: AVAsset(url: url), playerView: self.playerView)
                self.topBar.dropShadow()
                print(self.trimmerView.startTime?.seconds as Any)
                print(self.trimmerView.endTime?.seconds as Any)
                
            }
        }
        
    }
    
    private func layout(){
        self.view.addSubview(trimmerView)
        self.view.addSubview(playerView)
        self.view.addSubview(leftMaskView)
        self.view.addSubview(rightMaskView)
        self.view.addSubview(topBar)
        
        topBar.addSubview(backButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(nextButton)
        
        view.bringSubviewToFront(leftMaskView)
        view.bringSubviewToFront(rightMaskView)
        
        leftMaskView.layer.zPosition = 1
        rightMaskView.layer.zPosition = 1
        
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
        self.titleLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        self.playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.playerView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        self.playerView.topAnchor.constraint(equalTo: topBar.bottomAnchor).isActive = true
        
        self.trimmerView.translatesAutoresizingMaskIntoConstraints = false
        self.trimmerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16).isActive = true
        self.trimmerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16).isActive = true
        self.trimmerView.topAnchor.constraint(equalTo: self.playerView.bottomAnchor, constant: 70).isActive = true
        self.trimmerView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        self.leftMaskView.translatesAutoresizingMaskIntoConstraints = false
        self.leftMaskView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.leftMaskView.rightAnchor.constraint(equalTo: self.trimmerView.leftAnchor).isActive = true
        self.leftMaskView.topAnchor.constraint(equalTo: trimmerView.topAnchor).isActive = true
        self.leftMaskView.heightAnchor.constraint(equalTo: trimmerView.heightAnchor).isActive = true
        
        self.rightMaskView.translatesAutoresizingMaskIntoConstraints = false
        self.rightMaskView.leftAnchor.constraint(equalTo: trimmerView.rightAnchor).isActive = true
        self.rightMaskView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.rightMaskView.topAnchor.constraint(equalTo: trimmerView.topAnchor).isActive = true
        self.rightMaskView.heightAnchor.constraint(equalTo: trimmerView.heightAnchor).isActive = true
        
    }
    
    @objc func didTapBackBtn(){
        self.delegate?.didCancelController()
        self.stopPlaybackTimeChecker()
    }
    
    
    @objc func didTapNextBtn(){
        //  self.trimmerView.resetTrimmerView()
        stopPlaybackTimeChecker()
        let url = URL(string: self.assetURL)
        let startTime = trimmerView.startTime!
        let endTime = trimmerView.endTime!
        let destinationURL = createTemporaryDirectory().appendingPathComponent("\(randomInt).mp4")
        
        videoTrimmer.trimVideo(sourceURL: url!, destinationURL: destinationURL, trimPoints: [(startTime,endTime)],completion: {[weak self] (error,url,size) in
            if error == nil, let url = url, let size = size{
                DispatchQueue.main.async {[weak self] in
                    guard let self = self else {return}
                    let cuttedAsset = AVAsset(url:url)
                    let thumbGenerator = AVAssetImageGenerator(asset: cuttedAsset)
                    let cgImage : CGImage?
                    do{
                         cgImage = try thumbGenerator.copyCGImage(at: CMTimeMake(value: 5, timescale: 1), actualTime: nil)
                        
                        let image = UIImage(cgImage: cgImage!)
                        self.saveImage(image: image)
                        
                        let thumbnail : String = self.thumbnailImageUri
                        let mimeType : Any = "video/mp4"
                        
                        self.delegate?.didfinishWith(data: ["width":size.width,"height":size.height,"uri": url.absoluteString,"thumbnail": thumbnail, "mimetype":mimeType,"isTemporary":true])
                    }catch{
                        self.delegate?.didfinishWith(error: ["error":error])
                    }
                }
            }else{
                self?.delegate?.didfinishWith(error: ["error":error!])
            }
        })
    }
    
    private func saveImage(image: UIImage) {
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        
        let targetURL = tempDirectoryURL.appendingPathComponent("\(randomInt).jpg")
        
        if let data = image.jpegData(compressionQuality: thumbNailImageCompressionQuality) {
            do {
                try data.write(to: targetURL)
                self.thumbnailImageUri = targetURL.absoluteString
            } catch let error {
                self.delegate?.didfinishWith(error: ["error":error])
            }
        }
    }
    
    
    private func createTemporaryDirectory() -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
        return url
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
    
    private func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    private func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
        }
    }
    
    @objc func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
}

extension VideoCutterController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        print(trimmerView.startTime ?? CMTime.zero,trimmerView.endTime ?? CMTime.zero)
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
