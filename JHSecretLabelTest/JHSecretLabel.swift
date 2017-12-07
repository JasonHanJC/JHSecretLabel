//
//  JHSecretLabel.swift
//  JHSecretLabelTest
//
//  Created by Juncheng Han on 4/10/17.
//  Copyright © 2017 JasonH. All rights reserved.
//

import UIKit

enum JHSecretLabelStytle {
    case none
    case secrect
    case oneChar
    case oneWord
    case oneLine
}

class JHSecretLabel: UILabel {
    
    // Open properties
    open var showUpDuration: CFTimeInterval = 2.0 {
        didSet {
            self.calculateShowUpDelaysAndDurations()
        }
    }
    
    open var fadeOutDuration: CFTimeInterval = 2.0 {
        didSet {
            self.calculateFadeOutDelaysAndDurations()
        }
    }
    
    open var isAnimating: Bool {
        get {
            guard let displayLink = self.displayLink else {
                return false
            }
            return !displayLink.isPaused
        }
    }
    
    open var autoStarting: Bool = false
    
    open var style: JHSecretLabelStytle = .none {
        didSet {
            self.setupAttributedString()
            self.calculateShowUpDelaysAndDurations()
            self.calculateFadeOutDelaysAndDurations()
        }
    }

    // Private properties
    private var beginTime: CFTimeInterval?
    private var endTime: CFTimeInterval?
    
    // Is showing up or fading out: default is false
    private var fadingOut: Bool = false
    
    private var animationCompletion: (() -> Void)?
    
    private var displayLink: CADisplayLink?
    
    // Store the durration for each character
    private var showUpDurations: [Double] = []
    private var showUpDelays: [Double] = []
    
    private var fadeOutDurations: [Double] = []
    private var fadeOutDelays: [Double] = []
    
    // first Int is location, sec Int is length
    private var rangesOfWords: [(Int, Int)] = []
    
    private var mutableAttributedString: NSMutableAttributedString?
    
    override var attributedText: NSAttributedString? {
        didSet {
            self.setupAttributedString()
            self.calculateShowUpDelaysAndDurations()
            self.calculateFadeOutDelaysAndDurations()
        }
    }
    
    private func setupAttributedString() {
        guard let attributedText = attributedText else {
            return
        }
        mutableAttributedString = self.initTheAttributeStringFromAttributedText(attributedText)
        super.attributedText = self.mutableAttributedString
    }
    
    private func calculateShowUpDelaysAndDurations() {
        if style == .none {
            return
        }
        // clean the old data
        showUpDurations.removeAll()
        showUpDelays.removeAll()
        // calculate the new data
        guard let attributedText = self.mutableAttributedString, attributedText.length > 0, style != .none else {
            return
        }
        
        switch style {
        case .secrect:
            
            
            for i in 0...attributedText.length - 1 {
                showUpDelays.append(Double(arc4random_uniform(UInt32(showUpDuration / 2.0 * 100.0))) / 100.0)
                let remaining = showUpDuration - showUpDelays[i]
                showUpDurations.append(Double(arc4random_uniform(UInt32(remaining * 100.0))) / 100.0)
            }

        case .oneWord:
            let words = attributedText.string.characters.split(separator: " ").map(String.init)
            let showUpDurationForOneWord = showUpDuration / Double(words.count)
            
            rangesOfWords.removeAll()
            
            
            
            for i in 0...words.count - 1 {
                
                
                showUpDelays.append(showUpDurationForOneWord * Double(i))
                showUpDurations.append(showUpDurationForOneWord)
            }

    
        default:
            break
        }
        
    }
    
    private func calculateFadeOutDelaysAndDurations() {
        if style == .none {
            return
        }
        // clean the old data
        fadeOutDelays.removeAll()
        fadeOutDurations.removeAll()
        // calculate the new data
        guard let attributedText = self.mutableAttributedString, attributedText.length > 0 else {
            return
        }
        for i in 0...attributedText.length - 1 {
            fadeOutDelays.append(Double(arc4random_uniform(UInt32(fadeOutDuration / 2.0 * 100.0))) / 100.0)
            let remaining = fadeOutDuration - fadeOutDelays[i]
            fadeOutDurations.append(Double(arc4random_uniform(UInt32(remaining * 100.0))) / 100.0)
        }
        
    }
    
    override var text: String? {
        didSet {
            guard let text = text else {
                return
            }
            attributedText = NSAttributedString(string: text)
        }
    }
    
    override var textColor: UIColor! {
        didSet {
            self.setupAttributedString()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let text = self.text else {
            return
        }
        self.attributedText = NSAttributedString(string: text)
    }
    
    deinit {
        print("JHSecretLabel deinit")
    }
    
    // Public Functions
    open func showUp() {
        self.showUpWith(Completion: nil)
    }
    
    open func showUpWith(Completion completion: (() -> Void)?) {
        if style == .none {
            if let completion = completion {
                completion()
            }
            return
        }
        if !isAnimating && !fadingOut {
            animationCompletion = completion
            self.startAnimationWithDuration(Duration: self.showUpDuration)
        }
    }
    
    open func fadeOut() {
        self.fadeOutWith(Completion: nil)
    }
    
    open func fadeOutWith(Completion completion: (() -> Void)?) {
        if style == .none {
            if let completion = completion {
                completion()
            }
            return
        }
        if !isAnimating && fadingOut {
            animationCompletion = completion
            self.startAnimationWithDuration(Duration: self.fadeOutDuration)
        }
    }
    
    // Private Functions
    private func startAnimationWithDuration(Duration duration: CFTimeInterval) {
        self.beginTime = CACurrentMediaTime()
        self.endTime = self.beginTime! + duration
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(updateAttributedString))
        self.displayLink?.isPaused = false
        self.displayLink?.add(to: .current, forMode: .commonModes)
    }
    
    @objc private func updateAttributedString() {
        
        let curTime = CACurrentMediaTime()
        
        guard let str = self.mutableAttributedString?.string else {
            return
        }
        
        for (index, element) in str.unicodeScalars.enumerated() {
            
            if CharacterSet.whitespacesAndNewlines.contains(element) {
                continue
            }
            
            self.mutableAttributedString?.enumerateAttribute(NSForegroundColorAttributeName, in: NSMakeRange(index, 1), options: .longestEffectiveRangeNotRequired, using: { (value, range, stop) in
                
                let curCharAlpha = (value as! UIColor).cgColor.alpha
                
                let shouldUpdateAlpha = (self.fadingOut && curCharAlpha > 0) || (!self.fadingOut && curCharAlpha < 1)
    
                if !shouldUpdateAlpha {
                    return
                }
                
                if fadingOut {
                    let newCharAlpha = 1 - CGFloat((curTime - self.beginTime! - fadeOutDelays[index]) / fadeOutDurations[index])
                    
                    let newCharColor = self.textColor.withAlphaComponent(newCharAlpha)
                    self.mutableAttributedString?.addAttribute(NSForegroundColorAttributeName, value: newCharColor, range: range)
                } else {
                    let newCharAlpha = CGFloat((curTime - self.beginTime! - showUpDelays[index]) / showUpDurations[index])
                
                    let newCharColor = self.textColor.withAlphaComponent(newCharAlpha)
                    self.mutableAttributedString?.addAttribute(NSForegroundColorAttributeName, value: newCharColor, range: range)
                }
            })
        }
        
        super.attributedText = self.mutableAttributedString
        
        if curTime > self.endTime! {
            self.displayLink?.isPaused = true
            self.displayLink?.remove(from: .current, forMode: .commonModes)
            self.displayLink = nil
            
            self.fadingOut = !self.fadingOut
            
            if let completion = self.animationCompletion {
                completion()
                self.animationCompletion = nil
            }
        }
        
    }
    
    private func initTheAttributeStringFromAttributedText(_ attributedString: NSAttributedString) -> NSMutableAttributedString {
        
        if style == .none {
            return NSMutableAttributedString(attributedString: attributedString)
        } else {
            // Make each charactor's alpha to 0
            let tempMtbAttributedString = NSMutableAttributedString(attributedString: attributedString)
            let color = self.textColor.withAlphaComponent(0)
            tempMtbAttributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, tempMtbAttributedString.length))
        
            return tempMtbAttributedString
        }
    }

}

