//
//  ClassicViewController.swift
//  DrawBerry
//
//  Created by Jon Chua on 10/3/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

import UIKit
import PencilKit

class ClassicViewController: CanvasDelegateViewController {
    var classicGame: ClassicGame!
    var canvas: Canvas!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addCanvasToView()
        addDoneButtonToView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let votingVC = segue.destination as? VotingViewController {
            votingVC.classicGame = classicGame
            votingVC.classicGame.delegate = votingVC
            votingVC.classicGame.observePlayersDrawing()
        }
    }

    private func addCanvasToView() {
        let defaultSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height)

        let topLeftOrigin = CGPoint(x: self.view.bounds.minX, y: self.view.bounds.minY)
        let topLeftRect = CGRect(origin: topLeftOrigin, size: defaultSize)
        guard let canvas = BerryCanvas.createCanvas(within: topLeftRect) else {
            return
        }
        canvas.isClearButtonEnabled = true
        canvas.isUndoButtonEnabled = true
        canvas.delegate = self
        self.view.addSubview(canvas)
        self.canvas = canvas
    }

    private func addDoneButtonToView() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: self.view.frame.midX - 50, y: self.view.frame.maxY - 250,
                              width: 100, height: 50)
        button.backgroundColor = .systemYellow
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(doneOnTap(sender:)), for: .touchUpInside)

        self.view.addSubview(button)
    }

    @objc private func doneOnTap(sender: UIButton) {
        finishDrawing()
    }

    private func finishDrawing() {
        classicGame.addUsersDrawing(image: canvas.drawingImage)
        if classicGame.isRapid {
            performSegue(withIdentifier: "segueToVoting", sender: self)
        } else {
            performSegue(withIdentifier: "classicUnwindSegueToHomeVC", sender: self)
        }
    }
}
