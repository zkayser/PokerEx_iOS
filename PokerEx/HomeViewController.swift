import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let session = Session.decode(data: UserDefaults.standard.object(forKey: kSession) as? Data) {
            greetingLabel.text = "Welcome to PokerEx, \(session.player.username). You have \(session.player.chips) chips remaining."
        }
    }
}
