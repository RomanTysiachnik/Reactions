//
//  ViewController.swift
//  ReactionsExample
//
//  Created by Yannick LORIOT on 01/10/2016.
//  Copyright © 2016 Yannick Loriot. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet var reactionSelect: ReactionSelector!
  @IBOutlet var reactionButton: ReactionButton! {
    didSet {
      reactionButton.config = ReactionButtonConfig {
        $0.iconMarging = 8
        $0.spacing = 7
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.neutralTintColor = .gray
        $0.alignment = .centerLeft
        $0.hideTitle = true
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Reactions"
  }

  // MARK: - Action Methods

  @IBAction func reactionChangedAction(_: AnyObject) {
    guard let reaction = reactionSelect.selectedReaction else { return }

    reactionButton.reaction = reaction
    reactionButton.isSelected = false
  }
}
