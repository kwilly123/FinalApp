//
//  VC+CollectionDelegateExtension.swift
//  MixingApp-Final-Udacity-Project
//
//  Created by Kyle Wilson on 2020-04-06.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    //NUMBER OF ITEMS IN COLLECTION
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        print(sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects
    }
    
    //EACH CELL
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "track", for: indexPath) as! TrackCell
        let aTrack = self.fetchedResultsController.object(at: indexPath)
        print("TRACK \(aTrack)")
        cell.muteDelegate = self
        cell.soloDelegate = self
        cell.trackDelegate = self
        cell.trackLabel.text = "Track \n\(indexPath.row + 1)"
        print(cell)
        return cell
    }
    
    //CELL SIZE
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 113, height: 195)
    }
    
    //CELL SELECT
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        trackName.text = "Track \(indexPath.row + 1)"
    }
    
}
