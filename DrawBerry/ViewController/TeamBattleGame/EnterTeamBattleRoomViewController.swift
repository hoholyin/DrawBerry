//
//  EnterTeamBattleRoomViewController.swift
//  DrawBerry
//
//  Created by Calvin Chen on 8/4/20.
//  Copyright © 2020 DrawBerry. All rights reserved.
//

import UIKit
import Firebase

class EnterTeamBattleRoomViewController: UIViewController, EnterRoomViewController {
    static let roomType: GameRoomType = .TeamBattleRoom

    @IBOutlet private weak var background: UIImageView!
    @IBOutlet internal weak var roomCodeField: UITextField!
    @IBOutlet internal weak var errorLabel: UILabel!

    var roomEnteringNetwork: RoomEnteringNetwork!

    override func viewDidLoad() {
        super.viewDidLoad()
        background.image = Constants.roomBackground
        background.alpha = Constants.backgroundAlpha
        errorLabel.alpha = 0
        roomEnteringNetwork = FirebaseRoomEnteringNetworkAdapter()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let roomVC = segue.destination as? TeamBattleGameRoomViewController,
            let roomCodeValue = roomCodeField.text {
            let roomCode = RoomCode(value: roomCodeValue, type: .TeamBattleRoom)
            roomVC.room = TeamBattleGameRoom(roomCode: roomCode)
            roomVC.room.delegate = roomVC
            roomVC.configureStartButton()
        }
    }

    @IBAction private func backOnTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func joinOnTap(_ sender: UIButton) {
        joinRoom()
    }

    @IBAction private func createOnTap(_ sender: UIButton) {
        createRoom()
    }

    func segueToRoomVC() {
        performSegue(withIdentifier: "segueToTeamBattleRoom", sender: self)
    }

}
