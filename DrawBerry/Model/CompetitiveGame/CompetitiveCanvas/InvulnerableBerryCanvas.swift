//
//  InvulnerableBerryCanvas.swift
//  DrawBerry
//
//  Created by Jon Chua on 12/4/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

import UIKit

class InvulnerableBerryCanvas: BerryCanvas, CompetitiveCanvas {
    var decoratedCanvas: CompetitiveCanvas

    required init?(coder: NSCoder) {
        nil
    }

    internal init?(bounds: CGRect, canvas: CompetitiveCanvas) {
        self.decoratedCanvas = canvas
        super.init(canvas: canvas as? BerryCanvas ?? BerryCanvas())
    }

    static func decoratedCanvasFrom(canvas: CompetitiveCanvas) -> InvulnerableBerryCanvas? {
        InvulnerableBerryCanvas(bounds: canvas.bounds, canvas: canvas)
    }

    func addInkSplotch() {
        // Does nothing because the user is invulnerable
    }

    func rotateCanvas(by rotationValue: CGFloat) {
        // Does nothing because the user is invulnerable
    }

    func hideDrawing() {
        // Does nothing because the user is invulnerable
    }

    func showDrawing() {
        decoratedCanvas.isHidden = false
    }

    func removeDecorator(decoratorToRemove decorator: InvulnerableBerryCanvas) {
    }
}
