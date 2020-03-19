//
//  TestTogglePowerup.swift
//  DrawBerry
//
//  Created by Jon Chua on 15/3/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

import UIKit

class ChangeAlphaPowerup: TogglePowerup {
    var image = PowerupAssets.changeAlphaUIImage

    var owner: Player
    var targets: [Player]

    var location: CGPoint
    var duration: Double

    init(owner: Player, targets: [Player], location: CGPoint) {
        self.owner = owner
        self.targets = targets
        self.location = location
        self.duration = 1.0
    }

    func activate() {
        for target in targets {
            target.canvasDrawing.alpha = 0.2
        }
    }

    func deactivate() {
        for target in targets {
            target.canvasDrawing.alpha = 1
        }
    }
}
