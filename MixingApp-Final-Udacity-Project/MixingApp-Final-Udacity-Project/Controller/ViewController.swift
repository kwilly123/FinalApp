//
//  ViewController.swift
//  MixingApp-Final-Udacity-Project
//
//  Created by Kyle Wilson on 2020-03-27.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreData

class ViewController: UIViewController {
    
    var dataController: DataController!
    
    var blockOperation = BlockOperation()
    
    var fetchedResultsController: NSFetchedResultsController<Track>!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var goBackToStartButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var loopButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    
    
    @IBOutlet weak var eqcompView: UIView!
    @IBOutlet weak var knob1: Knob!
    @IBOutlet weak var knob2: Knob!
    @IBOutlet weak var knob3: Knob!
    @IBOutlet weak var knob4: Knob!
    @IBOutlet weak var knob5: Knob!
    @IBOutlet weak var knob6: Knob!
    @IBOutlet weak var knob7: Knob!
    @IBOutlet weak var knob8: Knob!
    
    @IBOutlet weak var knob1ValueLabel: UILabel!
    @IBOutlet weak var knob2ValueLabel: UILabel!
    @IBOutlet weak var knob3ValueLabel: UILabel!
    @IBOutlet weak var knob4ValueLabel: UILabel!
    @IBOutlet weak var knob5ValueLabel: UILabel!
    @IBOutlet weak var knob6ValueLabel: UILabel!
    @IBOutlet weak var knob7ValueLabel: UILabel!
    @IBOutlet weak var knob8ValueLabel: UILabel!
    
    @IBOutlet weak var trackName: UILabel!
    
    
    var knobs: [Knob] = []
    
    
    var audioEngine: AVAudioEngine = AVAudioEngine()
    var mixer: AVAudioMixerNode = AVAudioMixerNode()
    var audioPlayers = [AVAudioPlayerNode?](repeating: nil, count: 5)
    var equalizers = [AVAudioUnitEQ?](repeating: nil, count: 5)
    var reverb: AVAudioUnitReverb!
    
    var soloIndexPath: [IndexPath] = []
    
    var startSeconds: Int64!
    var currentSeconds: Int64!
    
    var filesArray = [AVAudioFile?](repeating: nil, count: 5)
    
    let numOfTracks = 6
    
    var project: Project!
    
    //MARK: SETUP FETCH CONTROLLER
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
        let predicate = NSPredicate(format: "project == %@", project)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "volume", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        print(fetchedResultsController.fetchRequest)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //MARK: VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PROJECT: \(project)")
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = flowLayout
        
        setupAudioEngine()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        collectionView.addGestureRecognizer(tapGestureRecognizer)
        
        reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.cathedral)
        reverb.wetDryMix = 50
        
        timeSlider.value = 0
        
        eqcompView.layer.borderWidth = 5
        eqcompView.layer.borderColor = UIColor.darkGray.cgColor
        
        knob1.renderer.pointerLayer.strokeColor = UIColor.yellow.cgColor
        knob1.minimumValue = 20
        knob1.maximumValue = 400
        knob2.renderer.pointerLayer.strokeColor = UIColor.systemPink.cgColor
        knob2.minimumValue = 400
        knob2.maximumValue = 2000
        knob3.renderer.pointerLayer.strokeColor = UIColor.orange.cgColor
        knob3.minimumValue = 2001
        knob3.maximumValue = 8000
        knob4.renderer.pointerLayer.strokeColor = UIColor.systemTeal.cgColor
        knob4.minimumValue = 8001
        knob4.maximumValue = 20000
        
        knob5.renderer.pointerLayer.strokeColor = UIColor.yellow.cgColor
        knob5.minimumValue = -96
        knob5.maximumValue = 24
        knob6.renderer.pointerLayer.strokeColor = UIColor.systemPink.cgColor
        knob6.minimumValue = -96
        knob6.maximumValue = 24
        knob7.renderer.pointerLayer.strokeColor = UIColor.orange.cgColor
        knob7.minimumValue = -96
        knob7.maximumValue = 24
        knob8.renderer.pointerLayer.strokeColor = UIColor.systemTeal.cgColor
        knob8.minimumValue = -96
        knob8.maximumValue = 24
        
        knobs = [knob1, knob2, knob3, knob4, knob5, knob6, knob7, knob8]
        //disable knobs
        disableKnobs()
        
        knob1.bringSubviewToFront(knob1ValueLabel)
        knob2.bringSubviewToFront(knob2ValueLabel)
        knob3.bringSubviewToFront(knob3ValueLabel)
        knob4.bringSubviewToFront(knob4ValueLabel)
        knob5.bringSubviewToFront(knob5ValueLabel)
        knob6.bringSubviewToFront(knob6ValueLabel)
        knob7.bringSubviewToFront(knob7ValueLabel)
        knob8.bringSubviewToFront(knob8ValueLabel)
        
        setupFetchedResultsController()
        
    }
    
    //MARK: ENABLE EQ KNOBS
    
    func enableKnobs() {
        for knob in knobs {
            knob.isUserInteractionEnabled = true
            knob.alpha = 1.0
        }
    }
    
    //MARK: DISABLE EQ KNOBS
    
    func disableKnobs() {
        for knob in knobs {
            knob.isUserInteractionEnabled = false
            knob.alpha = 0.5
        }
    }
    
    //MARK: SETUP EQ
    
    func setupEQ(equalizer: AVAudioUnitEQ) {
        equalizer.bands[0].filterType = .lowShelf
        equalizer.bands[0].bypass = false
        equalizer.bands[0].bandwidth = 2.0
        equalizer.bands[1].filterType = .parametric
        equalizer.bands[1].bypass = false
        equalizer.bands[1].bandwidth = 2.0
        equalizer.bands[2].filterType = .parametric
        equalizer.bands[2].bypass = false
        equalizer.bands[2].bandwidth = 2.0
        equalizer.bands[3].filterType = .highShelf
        equalizer.bands[3].bypass = false
        equalizer.bands[3].bandwidth = 2.0
    }
    
    var index: IndexPath!
    
    //MARK: CELL TAPPED
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer) {
        let pointInCollectionView = sender.location(in: collectionView)
        let indexPath = collectionView.indexPathForItem(at: pointInCollectionView)
        index = indexPath
        print(index ?? 0)
        if let indexPath = indexPath {
            trackName.text = "Track \(indexPath.row + 1)"
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackCell {
                if cell.audioPlayer == nil {
                    disableKnobs()
                } else {
                    enableKnobs()
                }
            } else {
                print("index nil")
            }
        } else {
            trackName.text = "Select a Track"
        }
    }
    
    
    
    func addFrequency(frequency: Float) {
        let eq = EQ(context: dataController.viewContext)
        eq.frequency = frequency
        try? dataController.viewContext.save()
        print("SAVING")
    }
    
    func addGain(gain: Float) {
        let eq = EQ(context: dataController.viewContext)
        eq.gain = gain
        try? dataController.viewContext.save()
    }
    
    
    @IBAction func knob1ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[0].frequency = knob1.value
        knob1ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[0].frequency ?? 0))"
        print(self.equalizers[self.index.row]?.bands[0].frequency ?? 0)
        let frequency = self.equalizers[self.index.row]?.bands[0].frequency ?? 0
        addFrequency(frequency: frequency)
    }
    
    @IBAction func knob2ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[1].frequency = knob2.value
        knob2ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[1].frequency ?? 0))"
        print(self.equalizers[self.index.row]?.bands[1].frequency ?? 0)
    }
    
    @IBAction func knob3ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[2].frequency = knob3.value
        knob3ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[2].frequency ?? 0))"
        print(self.equalizers[self.index.row]?.bands[2].frequency ?? 0)
    }
    
    
    @IBAction func knob4ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[3].frequency = knob4.value
        knob4ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[3].frequency ?? 0))"
        print(self.equalizers[self.index.row]?.bands[3].frequency ?? 0)
    }
    
    
    @IBAction func knob5ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[0].gain = knob5.value
        knob5ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[0].gain ?? 0))"
        print(self.equalizers[self.index.row]?.bands[0].gain ?? 0)
        let gain = self.equalizers[self.index.row]?.bands[0].gain ?? 0
        addGain(gain: gain)
    }
    
    
    @IBAction func knob6ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[1].gain = knob6.value
        knob6ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[1].gain ?? 0))"
        print(self.equalizers[self.index.row]?.bands[1].gain ?? 0)
    }
    
    
    @IBAction func knob7ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[2].gain = knob7.value
        knob7ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[2].gain ?? 0))"
        print(self.equalizers[self.index.row]?.bands[2].gain ?? 0)
    }
    
    
    @IBAction func knob8ValueChanged(_ sender: Any) {
        self.equalizers[self.index.row]?.bands[3].gain = knob8.value
        knob8ValueLabel.text = "\(Int(self.equalizers[self.index.row]?.bands[3].gain ?? 0))"
        print(self.equalizers[self.index.row]?.bands[3].gain ?? 0)
    }
    
    
    func setupAudioEngine() {
        DispatchQueue.global(qos: .background).async {
            self.audioEngine.attach(self.mixer)
            self.audioEngine.connect(self.mixer, to: self.audioEngine.outputNode, format: nil)
        }
    }
    
    func removeAudioPlayer(audioPlayer: AVAudioPlayerNode) {
        DispatchQueue.global(qos: .background).async {
            self.audioEngine.detach(audioPlayer)
            print("EQ's: \(String(describing: self.equalizers))")
            print("Track's: \(String(describing: self.audioPlayers))")
        }
    }
    
    func addAudioPlayer(audioPlayer: AVAudioPlayerNode) {
        DispatchQueue.global(qos: .background).async {
            
            let equalizer = AVAudioUnitEQ(numberOfBands: 4)
            
            self.setupEQ(equalizer: equalizer)
            
            self.audioEngine.attach(audioPlayer)
            print("AUDIO PLAYER: \(audioPlayer)")
            self.audioEngine.attach(equalizer)
            
            self.audioEngine.connect(audioPlayer, to: equalizer, format: nil)
            self.audioEngine.connect(equalizer, to: self.mixer, format: nil)
            
            self.audioPlayers.insert(audioPlayer, at: self.index.row)
            self.equalizers.insert(equalizer, at: self.index.row)
            print("EQ's: \(String(describing: self.equalizers))")
            print("Track's: \(String(describing: self.audioPlayers))")
            
            DispatchQueue.main.async {
                self.enableKnobs()
            }
        }
    }
    
    func attachFiles(audioFile: URL) {
        let fileURL = audioFile
        
        var file: AVAudioFile!
        
        do {
            try file = AVAudioFile(forReading: (fileURL.absoluteURL))
            print(file.length)
            filesArray.insert(file, at: self.index.row)
            print("FILES: \(String(describing: filesArray))")
            scheduleFiles()
        } catch let error {
            print("File Error: \(error.localizedDescription)")
        }
    }
    
    func addAudioFile(file: AVAudioFile) {
        let track = Track(context: dataController.viewContext)
        track.audio = file.url.dataRepresentation
        print(track.audio ?? "")
        print("Saving audio file")
        try? dataController.viewContext.save()
    }
    
    func addPan(pan: Float) {
        let track = Track(context: dataController.viewContext)
        track.pan = pan
        print("SAVING PAN")
        try? dataController.viewContext.save()
    }
    
    func scheduleFiles() {
        DispatchQueue.global(qos: .background).async {
            self.audioPlayers[self.index.row]?.scheduleFile((self.filesArray[self.index.row]!), at: nil, completionHandler: nil)
            if let audioFile = self.filesArray[self.index.row] {
                self.addAudioFile(file: audioFile)
            } else {
                print("Could not save audio file")
            }
        }
    }
    
    func playTracks() {
        DispatchQueue.global(qos: .background).async {
            for audioPlayer in self.audioPlayers {
                audioPlayer?.play(at: nil)
                print("Playing")
            }
        }
    }
    
    func pauseAudioEngine() {
        audioEngine.pause()
        playButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        playButton.isSelected = !playButton.isSelected
        if playButton.isSelected {
            do {
                try audioEngine.start()
                let sampleTime = audioEngine.outputNode.lastRenderTime?.sampleTime
                let sampleRate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
                startSeconds =  sampleTime! / AVAudioFramePosition(sampleRate)
                print(startSeconds ?? 0)
            } catch {
                print("Could not start audio engine")
            }
            playTracks()
            playButton.setBackgroundImage(UIImage(systemName: "stop"), for: .normal)
            playButton.isSelected = true
        } else {
            playButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
            playButton.isSelected = false
            audioEngine.pause()
            
            for audioPlayer in audioPlayers {
                audioPlayer?.pause()
            }
        }
    }
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            self.audioEngine.stop()
            do {
                try self.audioEngine.start()
            } catch {
                print(error)
            }
            for audioPlayer in self.audioPlayers {
                audioPlayer?.stop()
            }
            self.scheduleFilesToStart()
            DispatchQueue.main.async {
                self.playButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
                self.playButton.isSelected = false
            }
        }
    }
    
    func scheduleFilesToStart() {
        DispatchQueue.global(qos: .background).async {
            for (index, audioPlayer) in self.audioPlayers.enumerated() {
                if let file = self.filesArray[index] {
                    audioPlayer?.scheduleFile(file, at: nil, completionHandler: nil)
                    print(file)
                } else {
                    print("Audio File nil")
                }
            }
        }
    }
    
    @IBAction func timeSliderValueChanged(_ sender: Any) {
        if audioEngine.isRunning {
            let sampleTime = audioEngine.outputNode.lastRenderTime?.sampleTime
            let sampleRate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
            currentSeconds =  sampleTime! / AVAudioFramePosition(sampleRate)
            print(currentSeconds ?? 0)
        }
    }
    
}

extension ViewController: Solo, Mute, Tracks {
    
    func changePan(cell: TrackCell, pan: Float) {
        let indexPath = self.collectionView.indexPath(for: cell)
        index = indexPath
        print(index ?? 0)
        print("Changed Pan for Track \(indexPath?.row ?? 0) to \(pan)")
        addPan(pan: pan)
    }
    
    func changeVolume(cell: TrackCell, volume: Float) {
        let indexPath = self.collectionView.indexPath(for: cell)
        index = indexPath
        print(index ?? 0)
        print("Changed Volume for Track \(indexPath?.row ?? 0) to \(volume)")
    }
    
    func importTrack(cell: TrackCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        index = indexPath
        print(index ?? 0)
        let alert = UIAlertController(title: "Import Track", message: "Would you like to import an audio file into Track \(indexPath!.row + 1)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
            let documentPickerController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeMP3)], in: .import)
            documentPickerController.delegate = self
            self.present(documentPickerController, animated: true)
            
            cell.audioPlayer = AVAudioPlayerNode()
            
            if let audioPlayer = cell.audioPlayer {
                self.addAudioPlayer(audioPlayer: audioPlayer)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func removeTrack(cell: TrackCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        index = indexPath
        print(index ?? 0)
        let alert = UIAlertController(title: "Remove Track", message: "Would you like to remove an audio file on Track \(indexPath!.row + 1)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
            if let audioPlayer = cell.audioPlayer {
                self.removeAudioPlayer(audioPlayer: audioPlayer)
                self.filesArray.remove(at: indexPath!.row)
                self.audioPlayers.remove(at: indexPath!.row)
                self.equalizers.remove(at: indexPath!.row)
                
                print("Removed Audio Track at \(indexPath?.row ?? 0)")
                cell.importLight.backgroundColor = .clear
                cell.buttonRemove.isEnabled = false
                cell.buttonRemove.alpha = 0.5
                cell.buttonImport.isEnabled = true
                cell.buttonImport.alpha = 1.0
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func muteButtonTapped(cell: TrackCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        index = indexPath
        print(index ?? 0)
        print("Track \(indexPath?.row ?? 0) was muted!")
    }
    
    func soloButtonTapped(cell: TrackCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        index = indexPath
        print(index ?? 0)
        print("Track \(indexPath?.row ?? 0) was soloed!")
        //        soloIndexPath.append(indexPath!)
        for item in 0..<collectionView.numberOfItems(inSection: 0) where item != indexPath?.item {
            let indexPaths = IndexPath(item: item, section: 0)
            if let cell = collectionView.cellForItem(at: indexPaths) as? TrackCell {
                cell.isMuted = true
                cell.audioPlayer?.volume = 0
                cell.muteButton.tintColor = .muteBlue
                cell.muteButton.backgroundColor = .muteBlue
            } else {
                print("could not mute cells: \(indexPaths)")
            }
        }
    }
    
    func soloButtonTappedAgain(cell: TrackCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        index = indexPath
        print(index ?? 0)
        print("Track \(indexPath?.row ?? 0) was unsoloed!")
        //        soloIndexPath.remove(at: indexPath!.row)
        for item in 0..<collectionView.numberOfItems(inSection: 0) where item != indexPath?.item {
            let indexPaths = IndexPath(item: item, section: 0)
            if let cell = collectionView.cellForItem(at: indexPaths) as? TrackCell {
                cell.isMuted = false
                cell.audioPlayer?.volume = cell.volumeSlider.value
                cell.muteButton.tintColor = .clear
                cell.muteButton.backgroundColor = .clear
            }
        }
    }
}

