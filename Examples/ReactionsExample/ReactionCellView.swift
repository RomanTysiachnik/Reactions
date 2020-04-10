//
//  ReactionCellView.swift
//  ReactionsExample
//
//  Created by Yannick LORIOT on 20/08/2018.
//  Copyright © 2018 Yannick Loriot. All rights reserved.
//

import Foundation
import UIKit

final class ReactionCellView: UITableViewCell {
  @IBOutlet var avatarImageView: UIImageView! {
    didSet {
      avatarImageView.layer.masksToBounds = true
      avatarImageView.layer.cornerRadius = 18
    }
  }

  @IBOutlet var facebookReactionButton: ReactionButton! {
    didSet {
      facebookReactionButton.reactionSelector = ReactionSelector()
      facebookReactionButton.reactionSelector?.config = ReactionSelectorConfig {
        $0.showLabels = false
        $0.iconSize = 36
        $0.spacing = 7
      }
      facebookReactionButton.config = ReactionButtonConfig {
        $0.spacing = 8
        $0.font = UIFont(name: "HelveticaNeue", size: 15)
        $0.neutralTintColor = .lightGray
        $0.alignment = .centerLeft
      }
      facebookReactionButton.willShowSelector = feedback

      facebookReactionButton.reactionSelector?.feedbackDelegate = self
    }
  }

  @IBOutlet var reactionSummary: ReactionSummary! {
    didSet {
      reactionSummary.reactions = Reaction.facebook.all
      reactionSummary.setDefaultText(withTotalNumberOfPeople: 4, includingYou: true)
      reactionSummary.config = ReactionSummaryConfig {
        $0.spacing = 7
        $0.iconMarging = 6
        $0.font = UIFont(name: "HelveticaNeue", size: 12)
        $0.textColor = UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1)
        $0.alignment = .centerLeft
        $0.isAggregated = true
      }
    }
  }

  @IBOutlet var feedbackLabel: UILabel! {
    didSet {
      feedbackLabel.isHidden = true
    }
  }
  
  private let generator: UISelectionFeedbackGenerator = {
    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    return generator
  }()
  
  fileprivate func feedback() {
    generator.selectionChanged()
    generator.prepare()
  }


  // Actions

  @IBAction func facebookButtonReactionTouchedUpAction(_: AnyObject) {
    if facebookReactionButton.isSelected == false {
      facebookReactionButton.reaction = Reaction.facebook.like
    }
  }

  @IBAction func summaryTouchedAction(_: AnyObject) {
    facebookReactionButton.presentReactionSelector()
  }
}

extension ReactionCellView: ReactionFeedbackDelegate {
  func reactionFeedbackDidChanged(_ feedback: ReactionFeedback?) {
    feedbackLabel.isHidden = true

    feedbackLabel.text = feedback?.localizedString
  }
}
