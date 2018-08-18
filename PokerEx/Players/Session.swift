import Foundation

struct Session: Codable {
    let player: SessionPlayer
    
    struct SessionPlayer: Codable {
        let email: String?
        let token: String
        let username: String
        let chips: Int
    }
    
    static func decode(data: Data) -> Session? {
        return try? JSONDecoder().decode(Session.self, from: data)
    }
    
    static func decode(data: Data?) -> Session? {
        if let data = data {
            return decode(data: data)
        } else {
            return nil
        }
    }
}


