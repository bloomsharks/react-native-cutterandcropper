//
//  PryntTrimmerView.swift
//  PryntTrimmerView
//
//  Created by HHK on 27/03/2017.
//  Copyright © 2017 Prynt. All rights reserved.
//


import UIKit
import Photos

public protocol TrimmerViewDelegate: class {
    func didChangePositionBar(_ playerTime: CMTime)
    func positionBarStoppedMoving(_ playerTime: CMTime)
    func didChangeHandleBarPosition(StartTime:CMTime,EndTime:CMTime)
    func positionBarStartedMoving()
}

/// A view to select a specific time range of a video. It consists of an asset preview with thumbnails inside a scroll view, two
/// handles on the side to select the beginning and the end of the range, and a position bar to synchronize the control with a
/// video preview, typically with an `AVPlayer`.
/// Load the video by setting the `asset` property. Access the `startTime` and `endTime` of the view to get the selected time
// range
@IBDesignable public class TrimmerView: AVAssetTimeSelector {
    
    // MARK: - Properties
    
    // MARK: Color Customization
    
    /// The color of the main border of the view
    @IBInspectable public var mainColor: UIColor = UIColor.orange {
        didSet {
            updateMainColor()
        }
    }
    
    /// The color of the handles on the side of the view
    @IBInspectable public var handleColor: UIColor = UIColor.gray {
        didSet {
            updateHandleColor()
        }
    }
    
    /// The color of the position indicator
    @IBInspectable public var positionBarColor: UIColor = UIColor.white {
        didSet {
            positionBar.backgroundColor = positionBarColor
        }
    }
    
    // MARK: Interface
    
    public weak var delegate: TrimmerViewDelegate?
    
    // MARK: Subviews
    private let trimView = UIView()
    private let leftHandleView = HandlerView()
    private let rightHandleView = HandlerView()
    private let positionBar = UIView()
    private let leftHandleKnob = UIView()
    private let rightHandleKnob = UIView()
    private let leftMaskView = UIView()
    private let rightMaskView = UIView()
    private let leftHandleLabel = UILabel()
    private let rightHandleLabel = UILabel()
    private let leftHandleLabelLine = UIView()
    private let rightHandleLabelLine = UIView()
    
    // MARK: Constraints
    private var currentLeftConstraint: CGFloat = 0
    private var currentRightConstraint: CGFloat = 0
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var positionConstraint: NSLayoutConstraint?
    
    private let handleWidth: CGFloat = 15
    
    /// The minimum duration allowed for the trimming. The handles won't pan further if the minimum duration is attained.
    public var minDuration: Double = 1
    
    // MARK: - View & constraints configurations
    
    override func setupSubviews() {
        super.setupSubviews()
        backgroundColor = UIColor.clear
        layer.zPosition = 1
        setupTrimmerView()
        setupHandleView()
        setupMaskView()
        setupPositionBar()
        setupGestures()
        setupHandleLabel()
        updateMainColor()
        updateHandleColor()
        
        clipsToBounds = false
        
      
    }
    
    override func constrainAssetPreview() {
        assetPreview.leftAnchor.constraint(equalTo: leftAnchor, constant: handleWidth).isActive = true
        assetPreview.rightAnchor.constraint(equalTo: rightAnchor, constant: -handleWidth).isActive = true
        assetPreview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        assetPreview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func setupTrimmerView() {
        
        trimView.layer.borderWidth = 2.0
        trimView.layer.cornerRadius = 2.0
        trimView.translatesAutoresizingMaskIntoConstraints = false
        trimView.isUserInteractionEnabled = false
        addSubview(trimView)
        
        trimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        trimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftConstraint = trimView.leftAnchor.constraint(equalTo: leftAnchor)
        rightConstraint = trimView.rightAnchor.constraint(equalTo: rightAnchor)
        leftConstraint?.isActive = true
        rightConstraint?.isActive = true
    }
    
    private func setupHandleView() {
        
        leftHandleView.isUserInteractionEnabled = true
        leftHandleView.layer.cornerRadius = 2.0
        leftHandleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftHandleView)
        
        leftHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        leftHandleView.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
        leftHandleView.leftAnchor.constraint(equalTo: trimView.leftAnchor).isActive = true
        leftHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        leftHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        leftHandleView.addSubview(leftHandleKnob)
        
        leftHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        leftHandleKnob.widthAnchor.constraint(equalToConstant: 2).isActive = true
        leftHandleKnob.centerYAnchor.constraint(equalTo: leftHandleView.centerYAnchor).isActive = true
        leftHandleKnob.centerXAnchor.constraint(equalTo: leftHandleView.centerXAnchor).isActive = true
        
        rightHandleView.isUserInteractionEnabled = true
        rightHandleView.layer.cornerRadius = 2.0
        rightHandleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightHandleView)
        
        rightHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        rightHandleView.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
        rightHandleView.rightAnchor.constraint(equalTo: trimView.rightAnchor).isActive = true
        rightHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        rightHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        rightHandleView.addSubview(rightHandleKnob)
        
        rightHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        rightHandleKnob.widthAnchor.constraint(equalToConstant: 2).isActive = true
        rightHandleKnob.centerYAnchor.constraint(equalTo: rightHandleView.centerYAnchor).isActive = true
        rightHandleKnob.centerXAnchor.constraint(equalTo: rightHandleView.centerXAnchor).isActive = true
    }
    
    private func setupMaskView() {
        
        leftMaskView.isUserInteractionEnabled = false
        leftMaskView.backgroundColor = .white
        leftMaskView.alpha = 0.7
        leftMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(leftMaskView, belowSubview: leftHandleView)
        
        leftMaskView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftMaskView.rightAnchor.constraint(equalTo: leftHandleView.centerXAnchor).isActive = true
        
        rightMaskView.isUserInteractionEnabled = false
        rightMaskView.backgroundColor = .white
        rightMaskView.alpha = 0.7
        rightMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightMaskView, belowSubview: rightHandleView)
        
        rightMaskView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rightMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightMaskView.leftAnchor.constraint(equalTo: rightHandleView.centerXAnchor).isActive = true
    }
    
    func setupHandleLabel(){
        leftHandleLabel.font = UIFont.systemFont(ofSize: 14)
        rightHandleLabel.font = UIFont.systemFont(ofSize: 14)
        leftHandleLabel.textColor = .black
        rightHandleLabel.textColor = .black
        leftHandleLabelLine.backgroundColor = .black
        rightHandleLabelLine.backgroundColor = .black
        
        leftHandleLabelLine.isHidden = true
        rightHandleLabelLine.isHidden = true
        leftHandleLabel.isHidden = true
        rightHandleLabel.isHidden = true
        
        addSubview(leftHandleLabelLine)
        self.leftHandleLabelLine.translatesAutoresizingMaskIntoConstraints = false
        self.leftHandleLabelLine.bottomAnchor.constraint(equalTo: self.leftHandleView.topAnchor,constant: -2).isActive = true
        self.leftHandleLabelLine.centerXAnchor.constraint(equalTo: self.leftHandleView.centerXAnchor).isActive = true
        self.leftHandleLabelLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        self.leftHandleLabelLine.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        addSubview(rightHandleLabelLine)
        self.rightHandleLabelLine.translatesAutoresizingMaskIntoConstraints = false
        self.rightHandleLabelLine.bottomAnchor.constraint(equalTo: self.rightHandleView.topAnchor,constant: -2).isActive = true
        self.rightHandleLabelLine.centerXAnchor.constraint(equalTo: self.rightHandleView.centerXAnchor).isActive = true
        self.rightHandleLabelLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        self.rightHandleLabelLine.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        addSubview(leftHandleLabel)
        self.leftHandleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.leftHandleLabel.bottomAnchor.constraint(equalTo: self.leftHandleLabelLine.topAnchor,constant: 2).isActive = true
        self.leftHandleLabel.centerXAnchor.constraint(equalTo: self.leftHandleView.centerXAnchor).isActive = true
        
        addSubview(rightHandleLabel)
        self.rightHandleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightHandleLabel.bottomAnchor.constraint(equalTo: self.rightHandleLabelLine.topAnchor,constant: 2).isActive = true
         self.rightHandleLabel.centerXAnchor.constraint(equalTo: self.rightHandleView.centerXAnchor).isActive = true
    }
    
  private func updateHandleLabel(left leftHandleTimeStamp:CMTime? = nil, right rightHandleTimeStamp: CMTime? = nil){
       
    if let leftHandleAmountOfSecs = leftHandleTimeStamp?.seconds{
    if let leftHandleSecondsFormatted = secondsToHoursMinutesSeconds(seconds: leftHandleAmountOfSecs){
        let leftHandleLabelText : String!
        if (leftHandleAmountOfSecs) >= 3600.0{
            leftHandleLabelText = "\(leftHandleSecondsFormatted.0):\(leftHandleSecondsFormatted.1):\(leftHandleSecondsFormatted.2)"
        }else{
            leftHandleLabelText = "\(leftHandleSecondsFormatted.1):\(leftHandleSecondsFormatted.2)"
        }
        leftHandleLabel.text = leftHandleLabelText
    }
}
    
    if let rightHandleAmountOfSecs = rightHandleTimeStamp?.seconds {
        if let rightHandleSecondsFormatted = secondsToHoursMinutesSeconds(seconds: rightHandleAmountOfSecs){
            let rightHandleLabelText : String!
            if (rightHandleAmountOfSecs) >= 3600.0{
                rightHandleLabelText = "\(rightHandleSecondsFormatted.0):\(rightHandleSecondsFormatted.1):\(rightHandleSecondsFormatted.2)"
            }else{
               rightHandleLabelText = "\(rightHandleSecondsFormatted.1):\(rightHandleSecondsFormatted.2)"
            }
            rightHandleLabel.text = rightHandleLabelText
        }
    }
}
    
   private func secondsToHoursMinutesSeconds (seconds : Double) -> (String, String, String)? {
    let secondsRounded = round(seconds)
    let secondsRoundedInt = Int(secondsRounded)
    
    let hours = String(secondsRoundedInt / 3600)
    let minutes : String!
    if (secondsRoundedInt % 3600)/60 < 10 && (secondsRoundedInt % 3600)/60 > 0{
        minutes = "0\((secondsRoundedInt % 3600)/60)"
    }else{
        minutes = "\((secondsRoundedInt % 3600)/60)"
    }
    let seconds : String!
    if (secondsRoundedInt % 3600) % 60 < 10 {
        seconds = "0\((secondsRoundedInt % 3600) % 60)"
    }else{
        seconds = "\((secondsRoundedInt % 3600) % 60)"
    }
    return (hours, minutes,seconds)
    }
  
    
    private func setupPositionBar() {
        
        positionBar.frame = CGRect(x: 0, y: 0, width: 2, height: frame.height)
        positionBar.backgroundColor = positionBarColor
        positionBar.center = CGPoint(x: leftHandleView.frame.maxX, y: center.y)
        positionBar.layer.cornerRadius = 1
        positionBar.translatesAutoresizingMaskIntoConstraints = false
        positionBar.isUserInteractionEnabled = false
        addSubview(positionBar)
        
        positionBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        positionBar.widthAnchor.constraint(equalToConstant: 3).isActive = true
        positionBar.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        positionConstraint = positionBar.leftAnchor.constraint(equalTo: leftHandleView.rightAnchor, constant: 0)
        positionConstraint?.isActive = true
    }
    
    private func setupGestures() {
        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture))
        leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture))
        rightHandleView.addGestureRecognizer(rightPanGestureRecognizer)
        
    }
    
    private func updateMainColor() {
        trimView.layer.borderColor = UIColor.clear.cgColor//mainColor.cgColor
        leftHandleView.backgroundColor = mainColor
        rightHandleView.backgroundColor = mainColor
    }
    
    private func updateHandleColor() {
        leftHandleKnob.backgroundColor = handleColor
        rightHandleKnob.backgroundColor = handleColor
    }
    
    
    // MARK: - Trim Gestures
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard
            let view = gestureRecognizer.view,
            let superView = gestureRecognizer.view?.superview else { return }
        let isLeftGesture = view == leftHandleView
        switch gestureRecognizer.state {
        case .began:
            self.delegate?.positionBarStartedMoving()
            if isLeftGesture {
                leftHandleLabel.isHidden = false
                leftHandleLabelLine.isHidden = false
                currentLeftConstraint = leftConstraint!.constant
            } else {
                rightHandleLabel.isHidden = false
                rightHandleLabelLine.isHidden = false
                currentRightConstraint = rightConstraint!.constant
            }
            updateSelectedTime(stoppedMoving: false)
        case .changed:
            let translation = gestureRecognizer.translation(in: superView)
            if isLeftGesture {
                updateLeftConstraint(with: translation)
            } else {
                updateRightConstraint(with: translation)
            }
            layoutIfNeeded()
            if let startTime = startTime, isLeftGesture {
                seek(to: startTime)
            } else if let endTime = endTime {
                seek(to: endTime)
            }
            updateSelectedTime(stoppedMoving: false)
              self.delegate?.didChangeHandleBarPosition(StartTime: startTime!, EndTime: endTime!)
        case .cancelled, .ended, .failed:
            leftHandleLabel.isHidden = true
            leftHandleLabelLine.isHidden = true
            rightHandleLabel.isHidden = true
            rightHandleLabelLine.isHidden = true
              self.delegate?.didChangeHandleBarPosition(StartTime: startTime!, EndTime: endTime!)
            updateSelectedTime(stoppedMoving: true)
        default: break
        }
    }
    
    
    private func updateLeftConstraint(with translation: CGPoint) {
        let maxConstraint = max(rightHandleView.frame.origin.x - handleWidth - minimumDistanceBetweenHandle, 0)
        let newConstraint = min(max(0, currentLeftConstraint + translation.x), maxConstraint)
        leftConstraint?.constant = newConstraint
    }
    
    private func updateRightConstraint(with translation: CGPoint) {
        let maxConstraint = min(2 * handleWidth - frame.width + leftHandleView.frame.origin.x + minimumDistanceBetweenHandle, 0)
        let newConstraint = max(min(0, currentRightConstraint + translation.x), maxConstraint)
        rightConstraint?.constant = newConstraint
    }
    
    // MARK: - Asset loading
    
    override func assetDidChange(newAsset: AVAsset?) {
        super.assetDidChange(newAsset: newAsset)
        resetHandleViewPosition()
    }
    
    func resetTrimmerView(){
        assetPreview.resetScrollView()
        resetHandleViewPosition()
    }
    
    func resetHandleViewPosition() {
        leftConstraint?.constant = 0
        rightConstraint?.constant = 0
        layoutIfNeeded()
    }
    
    // MARK: - Time Equivalence
    
    /// Move the position bar to the given time.
    public func seek(to time: CMTime) {
        if let newPosition = getPosition(from: time) {
            
            let offsetPosition = newPosition - assetPreview.contentOffset.x - leftHandleView.frame.origin.x
            let maxPosition = rightHandleView.frame.origin.x - (leftHandleView.frame.origin.x + handleWidth)
                - positionBar.frame.width
            let normalizedPosition = min(max(0, offsetPosition), maxPosition)
            positionConstraint?.constant = normalizedPosition
            layoutIfNeeded()
        }
    }
    
    /// The selected start time for the current asset.
    public var startTime: CMTime? {
        let startPosition = leftHandleView.frame.origin.x + assetPreview.contentOffset.x
        let startTime = getTime(from: startPosition)
        updateHandleLabel(left: startTime)
        return startTime
    
    }
    
    /// The selected end time for the current asset.
    public var endTime: CMTime? {
        let endPosition = rightHandleView.frame.origin.x + assetPreview.contentOffset.x - handleWidth
        let endTime = getTime(from: endPosition)
        updateHandleLabel(right: endTime)
        return endTime
        
    }
    
    private func updateSelectedTime(stoppedMoving: Bool) {
        guard let playerTime = positionBarTime else {
            return
        }
        if stoppedMoving {
            delegate?.positionBarStoppedMoving(playerTime)
        } else {
            delegate?.didChangePositionBar(playerTime)
        }
    }
    
    private var positionBarTime: CMTime? {
        let barPosition = positionBar.frame.origin.x + assetPreview.contentOffset.x - handleWidth
        return getTime(from: barPosition)
    }
    
    private var minimumDistanceBetweenHandle: CGFloat {
        guard let asset = asset else { return 0 }
        return CGFloat(minDuration) * assetPreview.contentView.frame.width / CGFloat(asset.duration.seconds)
    }
    
    // MARK: - Scroll View Delegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedTime(stoppedMoving: true)

    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedTime(stoppedMoving: true)
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
         self.delegate?.positionBarStartedMoving()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.positionBar.frame.origin.x = self.leftHandleView.frame.maxX
        }
       
    }
}



