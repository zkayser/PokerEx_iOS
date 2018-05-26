import UIKit
import FacebookLogin

class SignInViewController: UIViewController {
    var loginButton: LoginButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.00, green:0.59, blue:0.53, alpha:1.0)
        loginButton = LoginButton(readPermissions: [.publicProfile, .email])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginButton.center.x -= view.bounds.width
        stackView.center.y -= self.view.bounds.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        runAnimations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func runAnimations() {
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut], animations: {
            self.stackView.center.y += self.view.bounds.height
        }, completion: nil)
        UIView.animate(
            withDuration: 1,
            delay: 0.5,
            options: [.curveEaseInOut],
            animations: {
                self.loginButton.center.x += self.view.bounds.width
                self.stackView.addArrangedSubview(self.loginButton)
        }, completion: nil)
    }
}

