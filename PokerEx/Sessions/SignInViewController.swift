import UIKit
import FacebookLogin
import FacebookCore

// Constants
fileprivate let leftMargin: CGFloat = 16
fileprivate let errorLabelMargin: CGFloat = 12
fileprivate let topMargin: CGFloat = 8
fileprivate let verticalSpacing: CGFloat = 25
fileprivate let buttonHeight: CGFloat = 50
fileprivate let borderWidth: CGFloat = 2
fileprivate let homeViewSegue = "HomeViewSegue"

class SignInViewController: UIViewController {

    private let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
    private var username: String?
    private var password: String?
    private var sessionLogicController: SessionLogicController!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var socialLoginContainer: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    lazy private var signInCallback: (Data?, URLResponse?, Error?) -> Void = { [weak self] data, response, error in
        guard let strongSelf = self else { return }
        guard let data = data, let response = response, error == nil else {
            strongSelf.renderBasicErrorMessage()
            return
        }

        UserDefaults.standard.set(data, forKey: kSession)
        DispatchQueue.main.async {
            strongSelf.performSegue(withIdentifier: homeViewSegue, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        socialLoginContainer.addSubview(loginButton)
        loginButton.frame = CGRect(x: leftMargin / 2, y: 0, width: UIScreen.main.bounds.width - (3 * leftMargin), height: buttonHeight)
        
        // add tap gesture recognizer to dismiss keyboard when tap anywhere on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // setup session logic controller
        sessionLogicController = SessionLogicController.shared
        
        // add a bottom border to text fields
        usernameField.layer.addSublayer(buildBottomBorderLayer())
        passwordField.layer.addSublayer(buildBottomBorderLayer())
        
        // set self as the delegate for text fields
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = AccessToken.current {
            sessionLogicController.facebookSignIn(errorCallback: renderBasicErrorMessage, completion: signInCallback)
        }
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        if identifier == homeViewSegue {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVc = storyboard.instantiateViewController(withIdentifier: kHomeViewController)
            self.present(homeVc, animated: false)
        }
    }
    
    // Actions
    @IBAction func signIn(_ sender: Any) {
        sessionLogicController.signIn(username: username, password: password, errorCallback: renderErrorMessage, completion: signInCallback)
    }
    
    @IBAction func signUp(_ sender: Any) {
        print("Pressed sign up")
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
        let borderLayer = CALayer()
        borderLayer.borderColor = UIColor.lightGray.cgColor
        borderLayer.frame = CGRect(x: leftMargin, y: usernameField.frame.size.height + 5, width: UIScreen.main.bounds.width - (4 * leftMargin), height: borderWidth)
        borderLayer.borderWidth = borderWidth
        return borderLayer
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

