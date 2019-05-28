import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn

// Constants
fileprivate let leftMargin: CGFloat = 16
fileprivate let errorLabelMargin: CGFloat = 12
fileprivate let topMargin: CGFloat = 8
fileprivate let verticalSpacing: CGFloat = 25
fileprivate let buttonHeight: CGFloat = 50
fileprivate let borderWidth: CGFloat = 2

class SignInViewController: UIViewController, SessionDelegateProtocol, GIDSignInUIDelegate {

    var username: String?
    var password: String?
    var sessionLogicController: SessionLogicControllerProtocol!
    var authentication: AuthenticationProtocol!
    var viewModel: SignInViewModel?
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    lazy var sessionCallback: DataTaskCallback = { [weak self] data, response, error in
        guard let strongSelf = self else { return }
        guard let data = data, let response = response, error == nil else {
            strongSelf.renderBasicErrorMessage()
            return
        }

        UserDefaults.standard.set(data, forKey: kSession)
        DispatchQueue.main.async {
            strongSelf.performSegue(withIdentifier: HOME_VIEW_SEGUE, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instantiate view model
        viewModel = SignInViewModel(parent: view, containerView: containerView, signInButton: signInButton)
        
        // set self as the delegate for Google Sign In UI and GoogleSignIn
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Add google sign in button
        viewModel?.renderGoogleSignIn(with: self)
        
        // add tap gesture recognizer to dismiss keyboard when tap anywhere on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // setup session logic controller
        sessionLogicController = SessionLogicController.shared
        
        // setup authentication handler
        authentication = Authentication.shared
        
        // add a bottom border to text fields
        usernameField.layer.addSublayer(buildBottomBorderLayer())
        passwordField.layer.addSublayer(buildBottomBorderLayer())
        
        // set self as the delegate for text fields
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        switch (authentication.getCredentials()) {
            case .session: performSegue(withIdentifier: HOME_VIEW_SEGUE, sender: nil)
            case .facebook: sessionLogicController.facebookSignIn(errorCallback: renderBasicErrorMessage, completion: sessionCallback)
            case .none: return
        }
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        if identifier == HOME_VIEW_SEGUE {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVc = storyboard.instantiateViewController(withIdentifier: kHomeViewController)
            self.present(homeVc, animated: false)
        }
    }
    
    // Actions
    @IBAction func signIn(_ sender: Any) {
        sessionLogicController.signIn(username: username, password: password, errorCallback: renderErrorMessage, completion: sessionCallback)
    }
    
    @objc func signInWithGoogle() {
        print("Inside signInWithGoogle action...")
        GIDSignIn.sharedInstance().signIn()
    }
    
    private func animate() {
        print("wire up animations here")
    }
    
    // UI Helpers
    func renderErrorMessage() {
        if (username == nil) {
            errorLabel(for: "username", on: usernameField)
        }
        
        if (password == nil) {
            errorLabel(for: "password", on: passwordField)
        }
    }
    
    func renderBasicErrorMessage() {
        let label = UILabel()
        label.text = "We're sorry. Something went wrong with your login. Please try again shortly."
        label.textColor = .red
        label.font.withSize(14)
        label.frame = CGRect(x: leftMargin, y: topMargin, width: view.frame.width, height: verticalSpacing)
        view.addSubview(label)
    }
    
    private func errorLabel(for property: String, on textField: UITextField) {
        let label = UILabel()
        label.text = "\(property.capitalized) must not be blank"
        label.textColor = .red
        label.textAlignment = .center
        label.font.withSize(14)
        label.frame = CGRect(x: textField.frame.minX, y: textField.frame.minY - errorLabelMargin, width: containerView.frame.width, height: verticalSpacing)
        containerView.addSubview(label)
    }
    
    private func buildBottomBorderLayer() -> CALayer {
        let line = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: signInButton.frame.minX, y: usernameField.frame.size.height))
        path.addLine(to: CGPoint(x: signInButton.frame.maxX, y: usernameField.frame.size.height))
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameField {
            username = textField.text
        } else {
            password = textField.text
        }
    }
}

extension SignInViewController: GIDSignInDelegate {
    // GOOGLE SIGN IN DELEGATE FUNCTIONS
    private func application(application: UIApplication,
                             openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var _: [String: AnyObject] = [UIApplicationOpenURLOptionsKey.sourceApplication.rawValue: sourceApplication as AnyObject,
                                      UIApplicationOpenURLOptionsKey.annotation.rawValue: annotation!]
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Running application:openUrl:options function with url: \(url)")
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let _ = error {
            renderBasicErrorMessage()
        } else {
            print("Signed in...")
            sessionLogicController.googleSignIn(email: user.profile.email, tokenId: user.authentication.idToken, errorCallback: renderBasicErrorMessage, completion: sessionCallback)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // I.E., in our case, we are going to have to remove the user's session
        // from UserDefaults dictionary, or wherever we end up storing session
        // information on the client later.
        print("User disconnected: \(user)")
    }
}

