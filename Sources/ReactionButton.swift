/*
 * Reactions
 *
 * Copyright 2016-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

/**
 A `ReactionButton` object is a control that executes a reaction in response to user interactions.

 You can tap a reaction button in order to highlight/unhighlight a reaction. You can also make a long press to the button to display a `ReactionSelector` if you have attached one.

 You can configure/skin the button using a `ReactionButtonConfig`.
 */
public final class ReactionButton: UIReactionControl {
  private var isSelectingReaction = false
  private let iconImageView: UIImageView = Components.ReactionButton.likeIcon()
  private let titleLabel: UILabel = Components.ReactionButton.likeLabel()
  
  private lazy var overlay: UIView = UIView().build {
    $0.clipsToBounds = false
    $0.backgroundColor = .clear
    $0.alpha = 0

    $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ReactionButton.dismissReactionSelector)))
  }

  public var isInitObserve: Bool = true
  public var likeReaction: Reaction?
  public var likedReaction: Reaction?
  public var didTapButton: ((_ sender: ReactionButton) -> Void)?
  public var didUpdateReaction: ((_ reaction: Reaction?) -> Void)?
  public var willShowSelector: (() -> Void)?
  public var didHideSelector: (() -> Void)?

  /**
   A Boolean value indicating whether the reaction button is in the selected state.
   */
  public override var isSelected: Bool {
    didSet { update() }
  }

  /**
   The reaction button configuration.
   */
  public var config: ReactionButtonConfig = ReactionButtonConfig() {
    didSet { update() }
  }

  /**
   The reaction used to build the button.

   The reaction `title` fills the button one, and the `alternativeIcon` is used to display the icon. If the `alternativeIcon` is nil, the `icon` is used instead.
   */
  public var reaction: Reaction? {
    didSet { update() }
  }

  /**
   The attached selector that the button will use in order to choose a reaction.

   There are two ways to display the selector: calling the `presentReactionSelector` method or by doing a long press to the button.
   */
  public var reactionSelector: ReactionSelector? {
    didSet { setupReactionSelect(old: oldValue) }
  }

  // MARK: - Building Object

  override func setup() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ReactionButton.tapAction)))
    addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(ReactionButton.longPressAction)))

    addSubview(iconImageView)
    addSubview(titleLabel)
  }

  private func setupReactionSelect(old: ReactionSelector?) {
    if let selector = reactionSelector {
      overlay.addSubview(selector)
    }

    old?.removeFromSuperview()
    old?.removeTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpInsideAction), for: .touchUpInside)
    old?.removeTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpOutsideAction), for: .touchUpOutside)

    reactionSelector?.addTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpInsideAction), for: .touchUpInside)
    reactionSelector?.addTarget(self, action: #selector(ReactionButton.reactionSelectorTouchedUpOutsideAction), for: .touchUpOutside)
  }

  // MARK: - Updating Object State

  override func update() {
    iconImageView.image = reaction?.alternativeIcon ?? reaction?.icon
    
    titleLabel.text = reaction?.title
    titleLabel.font = isSelected ? config.selectedFont : config.font

    let configSpacing = (config.hideIcon || config.hideTitle) ? 0 : config.spacing
    let iconSize = config.hideIcon ? 0
      : min(bounds.width - configSpacing, bounds.height) - config.iconMarging * 2
    let titleSize = config.hideTitle ? CGSize.zero
      : titleLabel.sizeThatFits(CGSize(width: bounds.width - iconSize,
                                       height: bounds.height))
    var iconFrame = CGRect(x: 0, y: (bounds.height - iconSize) / 2, width: iconSize, height: iconSize)
    var titleFrame = CGRect(x: iconSize + configSpacing, y: 0, width: titleSize.width, height: bounds.height)

    if config.alignment == .right {
      iconFrame.origin.x = bounds.width - iconSize
      titleFrame.origin.x = bounds.width - iconSize - configSpacing - titleSize.width
    } else if config.alignment == .centerLeft || config.alignment == .centerRight {
      let emptyWidth = bounds.width - iconFrame.width - titleLabel.bounds.width - configSpacing

      if config.alignment == .centerLeft {
        iconFrame.origin.x = emptyWidth / 2
        titleFrame.origin.x = emptyWidth / 2 + iconSize + configSpacing
      } else {
        iconFrame.origin.x = emptyWidth / 2 + titleSize.width + configSpacing
        titleFrame.origin.x = emptyWidth / 2
      }
    }

    iconImageView.frame = iconFrame
    titleLabel.frame = titleFrame
    
    UIView.transition(
      with: titleLabel,
      duration: config.selectionAnimationDuration,
      options: .transitionCrossDissolve,
      animations: { [unowned self] in
        let reactionColor = self.reaction?.color ?? self.config.neutralTintColor
        self.iconImageView.tintColor = self.isSelected ? reactionColor : self.config.neutralTintColor
        self.titleLabel.textColor = self.isSelected ? reactionColor : self.config.neutralTintColor
      }, completion: nil)
  }

  // MARK: - Responding to Gesture Events

  @objc func tapAction(_: UITapGestureRecognizer) {
    isSelected = !isSelected

    if isSelected {
      UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: .calculationModeCubic, animations: { [weak self] in
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
          self?.iconImageView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        })
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
          self?.iconImageView.transform = .identity
        })
        }, completion: nil)
    }

    sendActions(for: .touchUpInside)
    reaction = isSelected ? likedReaction : likeReaction
    didUpdateReaction?(isSelected ? likedReaction : nil)
    didTapButton?(self)
  }

  private var isLongPressMoved = false
  private var lastTouchedYPosition: CGFloat = 0

  @objc func longPressAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
    guard let selector = reactionSelector, selector.reactions.count > 1 else { return }
    lastTouchedYPosition = gestureRecognizer.location(in: self).y
    
    switch gestureRecognizer.state {
    case .began:
      isLongPressMoved = false
      displayReactionSelector(feedback: .slideFingerAcross)
    case .changed:
      isLongPressMoved = true
      _ = selector.longPressAction(gestureRecognizer)
    case .ended:
      if isLongPressMoved {
        let isPointInside = selector.longPressAction(gestureRecognizer)
        if isPointInside {
          dismissReactionSelector()
        } else {
          selector.feedback = .tapToSelectAReaction
        }
      } else {
        selector.feedback = .tapToSelectAReaction
      }
    default:
      break
    }
  }

  // MARK: - Responding to Select Events

  @objc func reactionSelectorTouchedUpInsideAction(_ sender: ReactionSelector) {
    guard let selectedReaction = sender.selectedReaction else { return }

    let isReactionChanged = reaction != selectedReaction || !isSelected

    reaction = selectedReaction
    isSelected = true

    if isReactionChanged {
      sendActions(for: .valueChanged)
    }

    dismissReactionSelector()
  }

  @objc func reactionSelectorTouchedUpOutsideAction(_: ReactionSelector) {
    dismissReactionSelector()
  }

  // MARK: - Presenting Reaction Selectors

  /**
   Presents the attached reaction selector.

   If no reaction selector is attached, the method does nothing.
   */
  public func presentReactionSelector() {
    displayReactionSelector(feedback: .tapToSelectAReaction)
  }

  /**
   Dismisses the attached reaction selector that was presented by the button.
   */
  @objc public func dismissReactionSelector() {
    guard isSelectingReaction else { return }
    isSelectingReaction = false
    reactionSelector?.feedback = nil
    didHideSelector?()
    animateOverlay(alpha: 0, center: CGPoint(x: overlay.bounds.midX, y: overlay.bounds.midY))
  }

  private func displayReactionSelector(feedback: ReactionFeedback) {
    guard let selector = reactionSelector,
      let window = UIApplication.shared.keyWindow,
      selector.reactions.count > 1 else { return }
    
    isSelectingReaction = true
    willShowSelector?()

    if overlay.superview == nil {
      window.addSubview(overlay)
    }

    overlay.frame = CGRect(x: 0, y: 0, width: window.bounds.width, height: window.bounds.height * 2)
    
    let centerPoint = convert(CGPoint(x: bounds.midX, y: 0), to: nil)

    selector.frame = selector.boundsToFit()
    
    switch config.alignment {
    case .left:
      selector.center = CGPoint(
        x: centerPoint.x + (selector.bounds.width - bounds.width) / 2,
        y: centerPoint.y + config.selectorOffset + bounds.height / 2)
    case .right:
      selector.center = CGPoint(
        x: centerPoint.x - (selector.bounds.width - bounds.width) / 2,
        y: centerPoint.y + config.selectorOffset + bounds.height / 2)
    default:
      selector.center = centerPoint
    }
    
    if selector.frame.origin.x - config.safeSelectorMargin < 0 {
      selector.center = CGPoint(
        x: selector.center.x - selector.frame.origin.x + config.safeSelectorMargin,
        y: centerPoint.y + config.selectorOffset + bounds.height / 2)
    } else if selector.frame.origin.x + selector.frame.width + config.safeSelectorMargin > overlay.bounds.width {
      selector.center = CGPoint(
        x: selector.center.x
          - (selector.frame.origin.x + selector.frame.width + config.safeSelectorMargin - overlay.bounds.width),
        y: centerPoint.y + config.selectorOffset + bounds.height / 2)
    }
    
    selector.feedback = feedback
    if selector.frame.origin.y - config.safeSelectorMargin < 0 {
      animateOverlay(alpha: 1, center: CGPoint(
        x: overlay.bounds.midX, y: overlay.bounds.midY + selector.bounds.height + bounds.height))
    } else {
      animateOverlay(alpha: 1, center: CGPoint(x
        : overlay.bounds.midX, y: overlay.bounds.midY - selector.bounds.height))
    }
  }

  private func animateOverlay(alpha: CGFloat, center: CGPoint) {
    UIView.animate(withDuration: 0.1) { [weak self] in
      guard let overlay = self?.overlay else { return }

      overlay.alpha = alpha
      overlay.center = center
    }
  }
}
