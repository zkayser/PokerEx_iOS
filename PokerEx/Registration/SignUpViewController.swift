import UIKit

// UI Value Constants
fileprivate let LEFT_MARGIN: CGFloat = 16
fileprivate let VERTICAL_SPACING: CGFloat = 8
fileprivate let LABEL_HEIGHT: CGFloat = 20

class SignUpViewController: UIViewController, SessionDelegateProtocol {
    
    var registration = Registration()
    var sessionLogicController: SessionLogicControllerProtocol!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    
    lazy var sessionCallback: DataTaskCallback = { [weak self] data, response, error in
        guard let strongSelf = self else { return }
        guard let data = data, let response = response, error == nil else {
            strongSelf.renderError()
            return
        }
        
        UserDefaults.standard.set(data, forKey: kSession)
        DispatchQueue.main.async {
            strongSelf.performSegue(withIdentifier: HOME_VIEW_SEGUE, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the session logic controller
        sessionLogicController = SessionLogicController.shared
        
        // Set self as the delegate for all text fields
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        messageField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVc = storyboard.instantiateViewController(withIdentifier: kHomeViewController)
        self.present(homeVc, animated: false)
    }
    
    @IBAction func signUp(_ sender: Any) {
        sessionLogicController.signUp(registration: registration, errorCallback: renderError, completion: sessionCallback)
    }
    
    private func renderError() {
        var errorMsg = ""
        if (registration.name == nil && registration.password == nil) {
            errorMsg = "Must enter username and password fields"
        } else if (registration.name == nil) {
            errorMsg = "Must enter username field"
        } else if (registration.password == nil) {
            errorMsg = "Must enter password field"
        } else if (registration.password != nil && registration.password!.count <= 5) {
            errorMsg = "Password must be at least six characters"
        } else {
            errorMsg = "Something went wrong. Please try again."
        }
        
        let label = UILabel()
        
        label.text = errorMsg
        label.textColor = .red
        label.textAlignment = .center
        label.font.withSize(14)
        label.frame = CGRect(x: LEFT_MARGIN, y: titleLabel.frame.maxY + VERTICAL_SPACING, width: view.bounds.size.width - LEFT_MARGIN, height: LABEL_HEIGHT)
        view.addSubview(label)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField) {
        case usernameField: registration.name = textField.text
        case passwordField: registration.password = textField.text
        case firstNameField: registration.firstName = textField.text
        case lastNameField: registration.lastName = textField.text
        case messageField: registration.blurb = textField.text
        case emailField: registration.email = textField.text
        default: return
        }
    }
}
