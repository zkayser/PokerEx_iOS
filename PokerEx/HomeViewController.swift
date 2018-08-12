import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedSession = UserDefaults.standard.object(forKey: kSession) as? Data {
            let decoder = JSONDecoder()
            if let session = try? decoder.decode(Session.self, from: savedSession) {
                greetingLabel.text = "Welcome to PokerEx, \(session.player.username). You have \(session.player.chips) chips remaining."
            }
        }
    }
}
