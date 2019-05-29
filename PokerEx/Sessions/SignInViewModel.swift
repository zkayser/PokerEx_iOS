//
//  SignInViewModel.swift
//  PokerEx
//
//  Created by Kayser, Zack (NonEmp) on 5/14/19.
//  Copyright © 2019 Kayser, Zack. All rights reserved.
//

import Foundation
import UIKit

// View Constants
fileprivate let leftMargin: CGFloat = 16
fileprivate let errorLabelMargin: CGFloat = 12
fileprivate let topMargin: CGFloat = 8
fileprivate let verticalSpacing: CGFloat = 25
fileprivate let buttonHeight: CGFloat = 50
fileprivate let borderWidth: CGFloat = 2
fileprivate let LOGIN_ERROR_MSG = "We're sorry. Something went wrong with your login. Please try again shortly."

class SignInViewModel {
    
    let parentView: UIView
    let containerView: UIView
    let signInButton: UIButton
    let textFields: [String: UITextField]
    
    init(parent view: UIView, containerView: UIView, signInButton: UIButton, textFields: [String: UITextField]) {
        self.parentView = view
        self.containerView = containerView
        self.signInButton = signInButton
        self.textFields = textFields
    }
    
    func renderGoogleSignIn(with delegate: SignInViewController) {
        let googleSignIn = UIButton(frame: CGRect(x: containerView.frame.minX + (leftMargin / 2), y: containerView.frame.maxY + verticalSpacing + buttonHeight, width: signInButton.frame.width, height: buttonHeight))
        // Setup label text
        googleSignIn.titleLabel?.textAlignment = .center
        googleSignIn.layer.backgroundColor = UIColor.blue.cgColor
        googleSignIn.setTitle("Sign In With Google", for: .normal)
        googleSignIn.setTitleColor(.white, for: .normal)
        googleSignIn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        
        // Set up image
        googleSignIn.setImage(#imageLiteral(resourceName: "GoogleLogo"), for: .normal)
        
        // Align image to left with centered text
        googleSignIn.layoutSubviews()
        googleSignIn.contentHorizontalAlignment = .left
        googleSignIn.contentEdgeInsets = UIEdgeInsets(top: googleSignIn.contentEdgeInsets.top, left: leftMargin, bottom: googleSignIn.contentEdgeInsets.bottom, right: googleSignIn.contentEdgeInsets.right)
        let availableSpace = UIEdgeInsetsInsetRect(googleSignIn.bounds, googleSignIn.contentEdgeInsets)
        let availableWidth = availableSpace.width - googleSignIn.imageEdgeInsets.right - (googleSignIn.imageView?.frame.width ?? 0) - (googleSignIn.titleLabel?.frame.width ?? 0)
        googleSignIn.titleEdgeInsets = UIEdgeInsets(top: 0, left: (availableWidth / 2), bottom: 0, right: 0)
        
        // Set action on view controller
        googleSignIn.addTarget(delegate, action: #selector(delegate.signInWithGoogle), for: .touchUpInside)
        parentView.addSubview(googleSignIn)
    }
    
    func buildBottomBorderLayer() -> CALayer {
        let line = CAShapeLayer()
        let path = UIBezierPath()
        let height = textFields["username"]!.frame.size.height
        path.move(to: CGPoint(x: signInButton.frame.minX, y: height))
        path.addLine(to: CGPoint(x: signInButton.frame.maxX, y: height))
        line.path = path.cgPath
        line.opacity = 1.0
        line.strokeColor = UIColor.lightGray.cgColor
        line.lineWidth = 2.0
        line.strokeStart = 0.5
        line.strokeEnd = 0.5
        
        let animationGroup = CAAnimationGroup()
        let strokeStartAnim = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnim.toValue = 0.0
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnim.toValue = 1.0
        animationGroup.animations = [strokeStartAnim, strokeEndAnim]
        animationGroup.fillMode = kCAFillModeBoth
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animationGroup.isRemovedOnCompletion = false
        animationGroup.duration = 0.75
        line.add(animationGroup, forKey: "strokeAnimation")
        return line
    }
    
    func renderErrorMessage() {
        guard let _ = textFields["username"]?.text else {
            errorLabel(for: "username", on: textFields["username"])
            return
        }
        
        guard let _ = textFields["password"]?.text else {
            errorLabel(for: "password", on: textFields["password"])
            return
        }
    }
    
    private func errorLabel(for property: String, on textField: UITextField?) {
        guard let textField = textField else { return }
        let label = UILabel()
        label.text = "\(property.capitalized) must not be blank"
        label.textColor = .red
        label.textAlignment = .center
        label.font.withSize(14)
        label.frame = CGRect(x: textField.frame.minX, y: textField.frame.minY - errorLabelMargin, width: containerView.frame.width, height: verticalSpacing)
        containerView.addSubview(label)
    }
    
    func renderUnauthenticatedError() {
        renderBasicErrorMessage(message: "Login failed. Please reenter your credentials and try again.")
    }
    
    func renderBasicErrorMessage(message: String = LOGIN_ERROR_MSG) {
            DispatchQueue.main.sync {
                guard let topMostTextField = self.textFields["username"] else { return }
                let label = UILabel()
                label.layer.backgroundColor = UIColor.red.cgColor
                label.text = message
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
                label.frame = CGRect(x: topMostTextField.frame.minX,
                                     y: topMostTextField.frame.minY - (verticalSpacing * 2.5),
                                     width: topMostTextField.frame.maxX - topMostTextField.frame.minX,
                                     height: verticalSpacing * 2.5)
                label.lineBreakMode = .byWordWrapping
                label.numberOfLines = 0
                label.textAlignment = .center
                topMostTextField.superview?.addSubview(label)
                
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
                    UIView.animate(withDuration: 0.5, animations: {
                        label.transform = CGAffineTransform(translationX: -(UIScreen.main.bounds.maxX), y: 0)
                    }, completion: { (_) in
                        label.removeFromSuperview()
                    })
                })
            }
    }
}
