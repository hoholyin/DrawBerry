//
//  CompetitiveVotingViewController.swift
//  DrawBerry
//
//  Created by Jon Chua on 2/4/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

import UIKit

class CompetitiveVotingViewController: UIViewController {
    var drawingList = [UIImage]()
    var drawingViews: [CompetitivePlayer: CompetitiveVotingView] = [:]
    var currentGame = CompetitiveGame()

    override func viewDidLoad() {
        super.viewDidLoad()
        addVotingViews()
    }

    /// Adds the four voting views for each player to vote.
    private func addVotingViews() {
        assert(drawingList.count == 4, "Player count should be 4")

        let defaultSize = CGSize(width: self.view.bounds.width / 2, height: self.view.bounds.height / 2)
        let minX = self.view.bounds.minX, maxX = self.view.bounds.maxX,
            minY = self.view.bounds.minY, maxY = self.view.bounds.maxY

        var playerNum = 0

        for y in stride(from: minY, to: maxY, by: (maxY + minY) / 2) {
            for x in stride(from: minX, to: maxX, by: (maxX + minX) / 2) {
                let rect = CGRect(origin: CGPoint(x: x, y: y), size: defaultSize)

                let drawingView = CompetitiveVotingView(frame: rect, listOfDrawings: drawingList,
                                                        listOfPlayers: currentGame.players,
                                                        currentPlayer: currentGame.players[playerNum])
                for drawing in drawingView.drawings {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
                    drawing.addGestureRecognizer(tapGesture)
                    drawing.isUserInteractionEnabled = true
                }

                if playerNum < 2 {
                    drawingView.transform = drawingView.transform.rotated(by: CGFloat.pi)
                }

                self.view.addSubview(drawingView)
                drawingViews[currentGame.players[playerNum]] = drawingView

                playerNum += 1
            }
        }
    }

    /// Assigns a vote from `playerWhoVoted` to the player `playerVotedFor`.
    /// Gives 2 votes if the player's drawing was voted as the best and 1 vote if voted as the second best drawing.
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? DrawingView else {
            return
        }

        let playerWhoVoted = tappedView.player
        let playerVotedFor = tappedView.drawingArtist
        let result = playerWhoVoted.voteFor(player: playerVotedFor)

        guard let playerVotingView = drawingViews[playerWhoVoted] else {
            return
        }
        playerVotingView.updateText(to: result)
        checkAllPlayersDoneVoting()
    }

    /// Checks if all players are done with voting, collates votes
    /// and assigns scores if so.
    private func checkAllPlayersDoneVoting() {
        if currentGame.players.map({ $0.isDoneVoting }).allSatisfy({ $0 }) {
            collateVotesAndAssignScores()
            currentGame.nextRound()
            currentGame.players.forEach { $0.resetVotes() }
            showNextButtons()
        }
    }

    /// Shows the current scoreboard of players sorted by score.
    private func showRankingScreen() {
        let sortedPlayersByScore = currentGame.players.sorted(by: { $0.score > $1.score })
        var rankingText = sortedPlayersByScore.map { "\($0.name): \($0.score)" }.joined(separator: "\n")

        if currentGame.isGameOver {
            rankingText = Message.competitiveVotingFinalResults + rankingText
        } else {
            rankingText = Message.competitiveVotingCurrentResults + rankingText
        }

        removeAllDrawings()
        drawingViews.values.forEach { $0.showResultText(text: rankingText) }
    }

    /// Removes all drawings from views.
    private func removeAllDrawings() {
        drawingViews.values.forEach { $0.drawings.forEach { $0.removeFromSuperview() } }
    }

    /// Collates votes and draws first and second place medals on the drawings.
    /// Also awards score to the players according to their rankings.
    /// If two players have the same number of votes, they are both awarded the medal and score.
    private func collateVotesAndAssignScores() {
        let sortedPlayersByVotes = currentGame.players.sorted(by: { $0.votesGiven > $1.votesGiven })

        var numberOfPlayersWithSimilarVotes = 0
        for i in 0...1 {
            let currentIndex = i + numberOfPlayersWithSimilarVotes
            if currentIndex >= sortedPlayersByVotes.count {
                break
            }

            let numberOfVotes = sortedPlayersByVotes[currentIndex].votesGiven
            let artist = sortedPlayersByVotes[currentIndex]

            if i == 0 {
                giveFirstPlaceMedal(to: artist)
                artist.score += CompetitiveGame.FIRST_PLACE_SCORE
            } else {
                giveSecondPlaceMedal(to: artist)
                artist.score += CompetitiveGame.SECOND_PLACE_SCORE
            }

            // Find players with similar votecount as previous artist
            while true {
                numberOfPlayersWithSimilarVotes += 1
                let nextIndex = i + numberOfPlayersWithSimilarVotes

                if nextIndex < sortedPlayersByVotes.count &&
                    sortedPlayersByVotes[nextIndex].votesGiven == numberOfVotes {
                    let nextArtist = sortedPlayersByVotes[nextIndex]
                    if i == 0 {
                        giveFirstPlaceMedal(to: nextArtist)
                        nextArtist.score += CompetitiveGame.FIRST_PLACE_SCORE
                    } else {
                        giveSecondPlaceMedal(to: nextArtist)
                        nextArtist.score += CompetitiveGame.SECOND_PLACE_SCORE
                    }
                } else {
                    numberOfPlayersWithSimilarVotes -= 1
                    break
                }
            }
        }

        disableVoting()
        updateVotingFinishedText()
    }

    /// Adds a first place medal image to the artist's drawing.
    private func giveFirstPlaceMedal(to artist: CompetitivePlayer) {
        for view in drawingViews.values {
            for drawing in view.drawings where drawing.drawingArtist == artist {
                drawing.addFirstPlaceMedal()
            }
        }
    }

    /// Adds a second place medal image to the artist's drawing.
    private func giveSecondPlaceMedal(to artist: CompetitivePlayer) {
        for view in drawingViews.values {
            for drawing in view.drawings where drawing.drawingArtist == artist {
                    drawing.addSecondPlaceMedal()
            }
        }
    }

    /// Disables voting for all players.
    private func disableVoting() {
        for view in drawingViews.values {
            for drawing in view.drawings {
                drawing.gestureRecognizers?.forEach { $0.isEnabled = false }
            }
        }
    }

    /// Updates voting text to the finished text once scores after collated and assigned.
    private func updateVotingFinishedText() {
        drawingViews.values.forEach { $0.updateText(to: Message.competitiveVotingResult) }
    }

    /// Shows the next buttons on players' views.
    private func showNextButtons() {
        for view in drawingViews.values {
            let nextButtonImageView = UIImageView(image: CompetitiveGame.NEXT_BUTTON)

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapNextButton(_:)))
            nextButtonImageView.addGestureRecognizer(tap)
            nextButtonImageView.isUserInteractionEnabled = true

            view.addNextButton(nextButtonImageView)
            view.isUserInteractionEnabled = true
        }
    }

    var playersReady = 0
    var rankingsShown = false
    @objc func handleTapNextButton(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        playersReady += 1

        if playersReady == currentGame.players.count {
            if !rankingsShown {
                showRankingScreen()
                rankingsShown = true
                showNextButtons()
                playersReady = 0
            } else {
                if currentGame.isGameOver {
                    performSegue(withIdentifier: "segueToMainMenu", sender: self)
                } else {
                    performSegue(withIdentifier: "segueToNextCompetitiveRound", sender: self)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let competitiveVC = segue.destination as? CompetitiveViewController {
            competitiveVC.competitiveGame = currentGame
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
