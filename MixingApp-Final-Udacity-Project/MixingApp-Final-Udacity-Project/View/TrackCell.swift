//
//  TrackCell.swift
//  MixingApp-Final-Udacity-Project
//
//  Created by Kyle Wilson on 2020-03-28.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import VerticalSlider
import AVFoundation

protocol Mute: AnyObject {
    func muteButtonTapped(cell: TrackCell)
}

protocol Solo: AnyObject {
    func soloButtonTapped(cell: TrackCell)
    func soloButtonTappedAgain(cell: TrackCell)
}

protocol Tracks: AnyObject {
    func importTrack(cell: TrackCell)
    func removeTrack(cell: TrackCell)
    func changeVolume(cell: TrackCell, volume: Float)
    func changePan(cell: TrackCell, pan: Float)
}

class TrackCell: UICollectionViewCell {
    
    var back: UIView!
    var front: UIView!
    var flip = true
    
    var audioPlayer: AVAudioPlayerNode?
    var isMuted = false
    
    @IBOutlet weak var volumeSlider: VerticalSlider!
    @IBOutlet weak var knob: Knob!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var soloButton: UIButton!
    @IBOutlet weak var panValueLabel: UILabel!
    @IBOutlet weak var importLight: UIView!
    @IBOutlet weak var trackLabel: UILabel!
    
    var buttonImport: UIButton!
    var buttonRemove: UIButton!
    
    weak var muteDelegate: Mute?
    weak var soloDelegate: Solo?
    weak var trackDelegate: Tracks?
    
    override func awakeFromNib() {
        
        muteButton.layer.borderColor = UIColor.white.cgColor
        muteButton.layer.borderWidth = 2
        soloButton.layer.borderColor = UIColor.white.cgColor
        soloButton.layer.borderWidth = 2
        volumeSlider.tintColor = .green
        volumeSlider.value = 0.5
        audioPlayer?.volume = volumeSlider.value
        panValueLabel.text = "0"
        self.bringSubviewToFront(panValueLabel)
        
        importLight.layer.borderColor = UIColor.gray.cgColor
        importLight.layer.borderWidth = 1
        
        
        
        createViews()
        
        let longTap = UITapGestureRecognizer(target: self, action: #selector(handleLongTap(sender:)))
        
        self.panValueLabel.addGestureRecognizer(longTap)
        panValueLabel.isUserInteractionEnabled = true
        
        self.bringSubviewToFront(panValueLabel)
    }
    
    @objc func handleLongTap(sender: UITapGestureRecognizer) {
        
        if flip {
            contentView.addSubview(back)
            UIView.transition(from: contentView, to: back, duration: 1, options: UIView.AnimationOptions.transitionFlipFromLeft, completion: nil)
            flip = false
        } else {
            UIView.transition(from: back, to: contentView, duration: 1, options: UIView.AnimationOptions.transitionFlipFromLeft, completion: nil)
            flip = true
        }
    }
    
    func createViews() {
        back = UIView(frame: self.frame)
        back.backgroundColor = .black
        buttonImport = UIButton(type: .system)
        buttonImport.frame = CGRect(x: 0, y: 0, width: 70, height: 45)
        buttonImport.setTitle("Import\nTrack", for: .normal)
        buttonImport.setTitleColor(.white, for: .normal)
        buttonImport.titleLabel?.textAlignment = .center
        buttonImport.titleLabel?.numberOfLines = 0
        buttonImport.layer.borderColor = UIColor.white.cgColor
        buttonImport.layer.borderWidth = 2
        buttonImport.center.x = back.center.x
        back.addSubview(buttonImport)
        buttonImport.addTarget(self, action: #selector(importTrack), for: .touchUpInside)
        buttonRemove = UIButton(type: .system)
        buttonRemove.frame = CGRect(x: 0, y: 50, width: 70, height: 45)
        buttonRemove.setTitle("Remove\nTrack", for: .normal)
        buttonRemove.setTitleColor(.white, for: .normal)
        buttonRemove.titleLabel?.textAlignment = .center
        buttonRemove.titleLabel?.numberOfLines = 0
        buttonRemove.layer.borderColor = UIColor.white.cgColor
        buttonRemove.layer.borderWidth = 2
        buttonRemove.center.x = back.center.x
        buttonRemove.isEnabled = false
        buttonRemove.alpha = 0.5
        back.addSubview(buttonRemove)
        buttonRemove.addTarget(self, action: #selector(removeTrack), for: .touchUpInside)
        let buttonGoBack = UIButton(type: .system)
        buttonGoBack.frame = CGRect(x: 0, y: 100, width: 70, height: 45)
        buttonGoBack.setTitle("Go\nBack", for: .normal)
        buttonGoBack.setTitleColor(.white, for: .normal)
        buttonGoBack.titleLabel?.textAlignment = .center
        buttonGoBack.titleLabel?.numberOfLines = 0
        buttonGoBack.layer.borderColor = UIColor.white.cgColor
        buttonGoBack.layer.borderWidth = 2
        buttonGoBack.center.x = back.center.x
        back.addSubview(buttonGoBack)
        buttonGoBack.addTarget(self, action: #selector(handleLongTap(sender:)), for: .touchUpInside)
    }
    
    @objc func importTrack() {
        trackDelegate?.importTrack(cell: self)
    }
    
    @objc func removeTrack() {
        trackDelegate?.removeTrack(cell: self)
    }
    
    @IBAction func muteButtonTapped(_ sender: Any) {
        if isMuted == true {
            muteButton.isSelected = false
            isMuted = false
            audioPlayer?.volume = volumeSlider.value
            muteButton.backgroundColor = .clear
            muteButton.tintColor = .clear
            trackDelegate?.changeVolume(cell: self, volume: audioPlayer?.volume ?? 0)
        } else {
            muteButton.isSelected = true
            isMuted = true
            muteDelegate?.muteButtonTapped(cell: self)
            audioPlayer?.volume = 0
            muteButton.backgroundColor = .muteBlue
            muteButton.tintColor = .muteBlue
            trackDelegate?.changeVolume(cell: self, volume: audioPlayer?.volume ?? 0)
        }
    }
    
    @IBAction func soloButtonTapped(_ sender: Any) {
        soloButton.isSelected = !soloButton.isSelected
        if soloButton.isSelected {
            soloDelegate?.soloButtonTapped(cell: self)
            soloButton.backgroundColor = .soloYellow
            soloButton.tintColor = .soloYellow
        } else {
            soloDelegate?.soloButtonTappedAgain(cell: self)
            soloButton.backgroundColor = .clear
            soloButton.tintColor = .clear
        }
    }
    
    
    @IBAction func volumeSliderValueChanged(_ sender: Any) {
        if isMuted {
            audioPlayer?.volume = 0
            print(audioPlayer?.volume ?? 0)
            trackDelegate?.changeVolume(cell: self, volume: audioPlayer?.volume ?? 0)
        } else {
            audioPlayer?.volume = volumeSlider.value
            print(audioPlayer?.volume ?? 0)
            trackDelegate?.changeVolume(cell: self, volume: audioPlayer?.volume ?? 0)
        }
    }
    
    @IBAction func knobValueChanged(_ sender: Any) {
        let newValue = Int(knob.value * 100)
        if knob.value > 0 {
            panValueLabel.text = "\(newValue)"
        } else if knob.value < 0 {
            panValueLabel.text = "\(newValue)"
        } else if knob.value == 0 {
            panValueLabel.text = "0"
        }
        audioPlayer?.pan = knob.value
        trackDelegate?.changePan(cell: self, pan: audioPlayer?.pan ?? 0)
    }
    
}

extension UIColor {
    static let muteBlue = UIColor(red: 81/255, green: 138/255, blue: 179/255, alpha: 1.0)
    static let soloYellow = UIColor(red: 255/255, green: 198/255, blue: 0/255, alpha: 1.0)
}
