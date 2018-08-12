import Foundation

struct Session: Codable {
    let player: SessionPlayer
    
    struct SessionPlayer: Codable {
        let email: String?
        let token: String
        let username: String
        let chips: Int
    }
}


