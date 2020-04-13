//
//  Project+Extensions.swift
//  MixingApp-Final-Udacity-Project
//
//  Created by Kyle Wilson on 2020-04-11.
//  Copyright © 2020 Xcode Tips. All rights reserved.
//

import Foundation

extension Project {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
