import UIKit
import FacebookLogin
import FacebookCore

fileprivate let leftMargin: CGFloat = 16
fileprivate let topMargin: CGFloat = 8
fileprivate let verticalSpacing: CGFloat = 25
fileprivate let buttonHeight: CGFloat = 50
fileprivate let borderWidth: CGFloat = 2

class SignInViewController: UIViewController {
    
    private let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(loginButton)
        loginButton.frame = CGRect(x: leftMargin - 8, y: containerView.bounds.size.height, width: UIScreen.main.bounds.width - (3 * leftMargin), height: buttonHeight)
        
        // add a bottom border to text fields
        usernameField.layer.addSublayer(buildBottomBorderLayer())
        passwordField.layer.addSublayer(buildBottomBorderLayer())
    }
    
    // Actions
    @IBAction func signIn(_ sender: Any) {
        print("pressed sign in")
    }
    
    @IBAction func signUp(_ sender: Any) {
        print("Pressed sign up")
    }
    
    private func animate() {
        print("wire up animations here")
    }
    
    private func buildBottomBorderLayer() -> CALayer {
        let borderLayer = CALayer()
        borderLayer.borderColor = UIColor.lightGray.cgColor
        borderLayer.frame = CGRect(x: leftMargin, y: usernameField.frame.size.height + 5, width: UIScreen.main.bounds.width - (4 * leftMargin), height: borderWidth)
        borderLayer.borderWidth = borderWidth
        return borderLayer
    }
}

