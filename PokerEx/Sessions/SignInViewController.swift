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
            strongSelf.viewModel!.renderBasicErrorMessage()
            return
        }
        
        if let response = response as? HTTPURLResponse {
            let statusCode = response.statusCode
            if (statusCode != 200) {
                strongSelf.viewModel!.renderUnauthenticatedError()
                return
            }
        }

        UserDefaults.standard.set(data, forKey: kSession)
        DispatchQueue.main.async {
            strongSelf.performSegue(withIdentifier: HOME_VIEW_SEGUE, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instantiate view model
        viewModel = SignInViewModel(parent: view,
                                    containerView: containerView,
                                    signInButton: signInButton,
                                    textFields: ["username": usernameField, "password": passwordField])
        
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
        if let viewModel = viewModel {
            usernameField.layer.addSublayer(viewModel.buildBottomBorderLayer())
            passwordField.layer.addSublayer(viewModel.buildBottomBorderLayer())
        }
        
        // set self as the delegate for text fields
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        switch (authentication.getCredentials()) {
            case .session: performSegue(withIdentifier: HOME_VIEW_SEGUE, sender: nil)
        case .facebook: sessionLogicController.facebookSignIn(
            errorCallback: { () in self.viewModel!.renderBasicErrorMessage() },
            completion: sessionCallback)
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
        print("You hit the signin button....")
        sessionLogicController.signIn(username: usernameField.text,
                                      password: passwordField.text,
                                      errorCallback: viewModel!.renderErrorMessage,
                                      completion: sessionCallback)
    }
    
    @objc func signInWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
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
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let _ = error {
            viewModel!.renderBasicErrorMessage()
        } else {
            sessionLogicController.googleSignIn(
                email: user.profile.email,
                tokenId: user.authentication.idToken,
                errorCallback: { () in self.viewModel!.renderBasicErrorMessage() },
                completion: sessionCallback)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        print("User disconnected: \(user)")
    }
}

