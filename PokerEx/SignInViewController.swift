import UIKit
import FacebookLogin
import FacebookCore

class SignInViewController: UIViewController {
    
    private let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(loginButton)
        let containerViewWidth = containerView.bounds.size.width
        let containerViewHeight = containerView.bounds.size.height
        loginButton.frame = CGRect(x: 16, y: containerViewHeight / 2, width: containerViewWidth, height: 50)
        
        // add a bottom border to text fields
        usernameField.layer.addSublayer(buildBottomBorderLayer())
        passwordField.layer.addSublayer(buildBottomBorderLayer())
    }
    
    private func animate() {
        print("wire up animations here")
    }
    
    private func buildBottomBorderLayer() -> CALayer {
        let borderLayer = CALayer()
        borderLayer.borderColor = UIColor.lightGray.cgColor
        borderLayer.frame = CGRect(x: 16, y: usernameField.frame.size.height + 5, width: usernameField.frame.size.width, height: 2)
        borderLayer.borderWidth = 2
        return borderLayer
    }
}

