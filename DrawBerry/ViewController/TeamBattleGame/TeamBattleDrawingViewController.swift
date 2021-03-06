//
//  TeamBattleDrawingViewController.swift
//  DrawBerry
//
//  Created by Calvin Chen on 8/4/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

import UIKit

class TeamBattleDrawingViewController: CanvasDelegateViewController {

    var game: TeamBattleGame!
    private var canvas: Canvas!
    private var topicTextLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        addCanvasToView()
        addDoneButtonToView()
        addTopicTextLabelToView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let teamBattleEndVC = segue.destination as? TeamBattleEndViewController {
            teamBattleEndVC.game = game
            teamBattleEndVC.game.resultDelegate = teamBattleEndVC
            teamBattleEndVC.game.observeAllTeamResult()
        }
    }

    /// Adds canvas to background.
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

    /// Adds topic text label to background.
    private func addTopicTextLabelToView() {
        let frame = CGRect(x: self.view.frame.midX - 150, y: 50, width: 300, height: 50)
        let topicTextLabel = UILabel(frame: frame)

        guard let topic = game.userTeam?.drawer.getDrawingTopic() else {
            return
        }

        topicTextLabel.text = "Round \(game.currentRound) Topic: \(topic)"
        topicTextLabel.textAlignment = .center
        topicTextLabel.font = UIFont(name: "Noteworthy", size: 30)
        self.topicTextLabel = topicTextLabel
        self.view.addSubview(topicTextLabel)
    }

    /// Changes topic in the text label.
    private func reloadTopicText() {
        guard let topic = game.userTeam?.drawer.getDrawingTopic() else {
            return
        }

        topicTextLabel.text = "Round \(game.currentRound) Topic: \(topic)"
    }

    /// Adds a button to the background
    private func addDoneButtonToView() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: self.view.frame.midX - 50, y: self.view.frame.maxY - 250,
                              width: 100, height: 50)
        button.backgroundColor = .systemYellow
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(doneOnTap(sender:)), for: .touchUpInside)

        self.view.addSubview(button)
    }

    /// Handles the tap gesture on the done button.
    @objc private func doneOnTap(sender: UIButton) {
        finishDrawing()
    }

    /// Reloads the canvas for a new game round.
    private func reloadCanvas() {
        canvas.removeFromSuperview()
        addCanvasToView()
        view.sendSubviewToBack(canvas)
    }

    /// Handles the event when player completed the drawing for one game round.
    private func finishDrawing() {
        game.addTeamDrawing(image: canvas.drawingImage)

        // Game ends
        if game.currentRound >= TeamBattleGame.maxRounds {
            performSegue(withIdentifier: "drawToTeamBattleEnd", sender: self)
            return
        }

        // Proceed to next round
        game.incrementRound()
        reloadCanvas()
        reloadTopicText()
    }

}
