//
//  VC+DocumentExtension.swift
//  MixingApp-Final-Udacity-Project
//
//  Created by Kyle Wilson on 2020-04-06.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.attachFiles(audioFile: urls[0])
        print("\(urls[0])")
        if let cell = collectionView.cellForItem(at: index) as? TrackCell {
            cell.importLight.backgroundColor = .clear
            cell.buttonRemove.isEnabled = true
            cell.buttonRemove.alpha = 1.0
            cell.importLight.backgroundColor = .blue
            cell.buttonImport.isEnabled = false
            cell.buttonImport.alpha = 0.5
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        disableKnobs()
        if let cell = collectionView.cellForItem(at: index) as? TrackCell {
            cell.importLight.backgroundColor = .clear
            cell.buttonImport.isEnabled = true
            cell.buttonImport.alpha = 1.0
            
        } else {
            print("Can't change import light color")
        }
        print("EQ's: \(String(describing: self.equalizers))")
        print("Track's: \(String(describing: self.audioPlayers))")
    }
    
}
