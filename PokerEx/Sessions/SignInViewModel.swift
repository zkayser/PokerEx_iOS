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

class SignInViewModel {
    
    let parentView: UIView
    let containerView: UIView
    let signInButton: UIButton
    
    init(parent view: UIView, containerView: UIView, signInButton: UIButton) {
        self.parentView = view
        self.containerView = containerView
        self.signInButton = signInButton
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
}
