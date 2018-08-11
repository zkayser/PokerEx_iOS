import UIKit
import FacebookLogin
import FacebookCore

fileprivate let leftMargin: CGFloat = 16
fileprivate let errorLabelMargin: CGFloat = 12
fileprivate let topMargin: CGFloat = 8
fileprivate let verticalSpacing: CGFloat = 25
fileprivate let buttonHeight: CGFloat = 50
fileprivate let borderWidth: CGFloat = 2

class SignInViewController: UIViewController {
    
    private let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
    private var username: String?
    private var password: String?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(loginButton)
        loginButton.frame = CGRect(x: leftMargin - 8, y: containerView.bounds.size.height, width: UIScreen.main.bounds.width - (3 * leftMargin), height: buttonHeight)
        
        // add tap gesture recognizer to dismiss keyboard when tap anywhere on screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // add a bottom border to text fields
        usernameField.layer.addSublayer(buildBottomBorderLayer())
        passwordField.layer.addSublayer(buildBottomBorderLayer())
        
        // set self as the delegate for text fields
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    // Actions
    @IBAction func signIn(_ sender: Any) {
        guard let username = self.username, let password = self.password else {
            renderErrorMessage()
            return
        }
        print("URL: \(NetworkUtils.backendUrl())")
        guard let url = URL(string: "\(NetworkUtils.backendUrl())api/sessions") else { return }
        var json = [String: Any]()
        var player = [String: Any]()
        player["username"] = username
        player["password"] = password
        json["player"] = player
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                guard let response = response else {
                    print("Couldn't get the response")
                    return
                }
                print("Response: \(response)")
                print("And the data: \(data)")
            }
            task.resume()
        } catch {
            print("Failed...")
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        print("Pressed sign up")
    }
    
    private func animate() {
        print("wire up animations here")
    }
    
    // UI Helpers
    private func renderErrorMessage() {
        if (username == nil) {
            errorLabel(for: "username", on: usernameField)
        }
    
        if (password == nil) {
            errorLabel(for: "password", on: passwordField)
        }
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

