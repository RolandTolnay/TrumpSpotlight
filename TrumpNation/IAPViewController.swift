//
//  IAPViewController.swift
//  TrumpNation
//
//  Created by Roland Tolnay on 5/12/17.
//  Copyright © 2017 Agilio. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class IAPViewController: UIViewController {
   
   // MARK: -
   // MARK: IBOutlets
   @IBOutlet weak var imageView: UIImageView!
   @IBOutlet weak var subscribeButton: UIButton!
   @IBOutlet weak var dismissButton: UIButton!
   
   @IBOutlet weak var startTrialLabel: UILabel!
   @IBOutlet weak var meetTheManLabel: UILabel!
   @IBOutlet weak var logoImageView: UIImageView!
   @IBOutlet weak var disclaimerLabel: UILabel!
   
   fileprivate var activityIndicator: NVActivityIndicatorView!
   fileprivate var blurView: UIVisualEffectView!
   
   // MARK: -
   // MARK: Constraints
   // --------------------
   @IBOutlet weak var subscribeToBottom: NSLayoutConstraint!
   @IBOutlet weak var subscribeToStartTrial: NSLayoutConstraint!

   // MARK: -
   fileprivate let manager = SubscriptionManager()
   fileprivate let productId = SubscriptionManager.subscriptionProductId
   
   // MARK: -
   // MARK: Properties
   var viewHeader: IAPViewHeader = .logo
   var isDismissable = true
   var trialState: TrialState = .ended
   
   var delegate: IAPViewControllerDelegate?
   
   // MARK: -
   // MARK: Lifecycle
   // --------------------
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setupProductPrice()
      setupGestureRecognizers()
      setupLabels()
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      
      setupViewFor(dismissable: isDismissable)
      setupViewFor(trialState: trialState)
      setupViewFor(viewHeader: viewHeader)
      
      setupLoadingIndicator()
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      Utility.lockOrientation(.portrait, andRotateTo: .portrait)
      
      let trialState = SubscriptionManager.trialState.rawValue
      let remainingDays = SubscriptionManager.remainingTrialDays
      FirLogger.newEvent(named: "purchase-shown", parameters: ["trial-state":trialState,
                                                               "remaining-trial": remainingDays])
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      Utility.lockOrientation(.all)
      
      let trialState = SubscriptionManager.trialState.rawValue
      let remainingDays = SubscriptionManager.remainingTrialDays
      FirLogger.newEvent(named: "purchase-hidden", parameters: ["trial-state":trialState,
                                                                "remaining-trial": remainingDays])
   }
   
   // MARK: -
   // MARK: Setup
   // --------------------
   func setupProductPrice() {
      if IAPHelper.shared.productCount == 0 {
         setupProducts()
      } else {
         let priceText = SubscriptionManager().priceText(for: SubscriptionManager.subscriptionProductId)
         setupSubscribeButton(with: priceText!)
         self.subscribeButton.isEnabled = true
      }
   }
   
   private func setupProducts() {
      subscribeButton.isEnabled = false
      IAPHelper.shared.requestProducts(withIds: [SubscriptionManager.subscriptionProductId]) { [unowned self] products, error in
         guard error == nil else {
            self.dismiss()
            return
         }
         
         DispatchQueue.main.async { [unowned self] in
            self.subscribeButton.isEnabled = true
            
            let priceText = SubscriptionManager().priceText(for: SubscriptionManager.subscriptionProductId)
            self.setupSubscribeButton(with: priceText!)
         }
      }
   }
   
   private func setupGestureRecognizers() {
      let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe(gesture:)))
      swipeDown.direction = .down
      self.view.addGestureRecognizer(swipeDown)
      
      if trialState == .notStarted {
         let trialTap = UITapGestureRecognizer(target: self, action: #selector(onStartTrialTapped(gesture:)))
         startTrialLabel.addGestureRecognizer(trialTap)
      }
   }
   
   private func setupLoadingIndicator() {
      let blurEffect = UIBlurEffect(style: .dark)
      blurView = UIVisualEffectView(effect: blurEffect)
      blurView.frame = view.bounds
      blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.addSubview(blurView)
      blurView.isHidden = true
      
      let indicatorSize = CGFloat(66.0)
      let x = (self.view.frame.width / 2) - (indicatorSize / 2)
      let y = (self.view.frame.height / 2) - (indicatorSize * 2)
      let frame = CGRect(x: x, y: y, width: indicatorSize, height: indicatorSize)
      activityIndicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: defaultWhite)
      view.addSubview(activityIndicator)
      view.bringSubview(toFront: activityIndicator)
      activityIndicator.isHidden = true
   }
   
   private func setupLabels() {
      meetTheManLabel.layer.masksToBounds = false
      meetTheManLabel.layer.shadowColor = UIColor.black.cgColor
      meetTheManLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
      meetTheManLabel.layer.shadowOpacity = 0.5
      meetTheManLabel.layer.shadowRadius = 5
      
      let mtmFontSize: CGFloat = Utility.isSmallScreen ? 30 : 34
      meetTheManLabel.font = UIFont(name: "Lato-Bold", size: mtmFontSize)
      let startTrialFontSize: CGFloat = Utility.isSmallScreen ? 16 : 20
      startTrialLabel.font = UIFont(name: "Lato-Bold", size: startTrialFontSize)
   }
   
   // MARK: -
   // MARK: Dynamic UI
   // --------------------
   private func setupViewFor(trialState: TrialState) {
      switch trialState {
      case .ended:
         trialStateEnded()
      case .inProgress:
         trialStateInProgress()
      case .notStarted:
         trialStateNotStarted()
      }
   }
   
   private func trialStateEnded() {
      startTrialLabel.isHidden = true
      subscribeToStartTrial.isActive = false
      subscribeToBottom.isActive = true
      subscribeButton.isHidden = false
      disclaimerLabel.isHidden = false
   }
   
   private func trialStateInProgress() {
      startTrialLabel.isHidden = false
      let remaining = SubscriptionManager.remainingTrialDays
      let dayString = remaining > 1 ? "days" : "day"
      startTrialLabel.text = "You have \(remaining) \(dayString) trial left"
      startTrialLabel.textColor = .lightGray
      startTrialLabel.isUserInteractionEnabled = false
      subscribeToStartTrial.isActive = true
      subscribeToBottom.isActive = false
      subscribeButton.isHidden = false
      disclaimerLabel.isHidden = false
   }
   
   private func trialStateNotStarted() {
      startTrialLabel.isHidden = false
      let trialDays = SubscriptionManager.remainingTrialDays
      startTrialLabel.text = "Continue to latest headlines"
      startTrialLabel.textColor = defaultWhite
      startTrialLabel.isUserInteractionEnabled = true
      subscribeToStartTrial.isActive = true
      subscribeToBottom.isActive = false
      subscribeButton.isHidden = true
      disclaimerLabel.isHidden = true
   }
   
   private func setupViewFor(dismissable: Bool) {
      dismissButton.isHidden = !isDismissable
   }
   
   private func setupViewFor(viewHeader: IAPViewHeader) {
      switch viewHeader {
      case .logo:
         meetTheManLabel.isHidden = true
         logoImageView.isHidden = false
      case .label:
         meetTheManLabel.isHidden = false
         logoImageView.isHidden = true
      }
   }
   
   private func setupSubscribeButton(with priceText: String) {
      let subscribeFontSize: CGFloat = Utility.isSmallScreen ? 20 : 24
      let priceFontSize: CGFloat = Utility.isSmallScreen ? 14 : 18
      
      subscribeButton.titleLabel?.lineBreakMode = .byWordWrapping
      
      let buttonText = "SUBSCRIBE NOW\nOnly \(priceText)/month"
      let buttonAttText = NSMutableAttributedString(string: buttonText)
      
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineSpacing = 0
      paragraphStyle.alignment = .center
      
      let subscribeFont = UIFont(name: "Lato-Bold", size: subscribeFontSize)
      let subscribeAttributes = [ NSParagraphStyleAttributeName: paragraphStyle,
                                  NSFontAttributeName: subscribeFont!,
                                  NSForegroundColorAttributeName: defaultWhite ]
      
      let priceFont = UIFont(name: "Lato-Italic", size: priceFontSize)
      let priceAttributes = [ NSParagraphStyleAttributeName: paragraphStyle,
                              NSFontAttributeName: priceFont!,
                              NSForegroundColorAttributeName: defaultWhite ]
      
      let lines = buttonText.components(separatedBy: "\n")
      let subscribe = lines[0]
      let price = lines[1]
      
      buttonAttText.setAttributes(subscribeAttributes, range: NSMakeRange(0, subscribe.length))
      buttonAttText.setAttributes(priceAttributes, range: NSMakeRange(subscribe.length + 1, price.length))
      
      subscribeButton.setAttributedTitle(buttonAttText, for: .normal)
   }
   
   // MARK: -
   // MARK: Actions
   // --------------------
   @IBAction func onSubscribeTapped(_ sender: Any) {
      startLoading()
      
      self.logIAPEvent(named: "purchase-start")
      IAPHelper.shared.buyProduct(withId: SubscriptionManager.subscriptionProductId) { [unowned self] productId, error in
         self.stopLoading()
         guard error == nil else {
            Navigator.shared.presentDialog(for: error!)
            
            if let error = error as? IAPError {
               if error == IAPError.cancelled {
                  self.logIAPEvent(named: "purchase-cancelled")
               } else {
                  let message = IAPError.message(from: error)
                  self.logIAPEvent(named: "purchase-error", message: message)
               }
            } else {
               self.logIAPEvent(named: "purchase-error", message: error!.localizedDescription)
            }
            
            return
         }
         
         SubscriptionManager.isSubscribed = true
         DispatchQueue.main.async {
            self.dismiss()
            self.delegate?.iapViewController(self, didUnlock: productId!)
         }
         self.logIAPEvent(named: "purchase-succes")
      }
   }
   
   @IBAction func onDismissTapped(_ sender: Any) {
      dismiss()
      
      logIAPEvent(named: "purchase-dismissed")
   }
   
   @objc private func onStartTrialTapped(gesture: UIGestureRecognizer) {
      dismiss(animated: true, completion: nil)
      SubscriptionManager().startedTrial(for: &UserManager.user!)
   }
   
   @objc private func onSwipe(gesture: UIGestureRecognizer) {
      dismiss()
      
      logIAPEvent(named: "purchase-dismissed")
   }
   
   private func dismiss() {
      if isDismissable {
         dismiss(animated: true, completion: nil)
      }
   }
   
   // MARK: -
   private func logIAPEvent(named name: String, message: String? = nil) {
      let trialState = SubscriptionManager.trialState.rawValue
      let remainingDays = SubscriptionManager.remainingTrialDays
      FirLogger.newEvent(named: name,
                         parameters: ["trial-state":trialState,
                                      "remaining-trial": remainingDays,
                                      "message": message ?? ""])
   }
}
// MARK: -
// MARK: Loading
// --------------------
extension IAPViewController {
   
   fileprivate func startLoading() {
      DispatchQueue.main.async {
         self.blurView.isHidden = false
         self.activityIndicator.startAnimating()
      }
   }
   
   fileprivate func stopLoading() {
      DispatchQueue.main.async {
         self.blurView.isHidden = true
         self.activityIndicator.stopAnimating()
      }
   }
}
// MARK: -
protocol IAPViewControllerDelegate {
   
   func iapViewController(_ viewController: IAPViewController, didUnlock productId:ProductId)
}
// MARK: -
enum IAPViewHeader {
   case logo
   case label
}
