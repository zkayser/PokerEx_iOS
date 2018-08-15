import Foundation
import FacebookCore

class Authentication {
    
    static var shared: Authentication = Authentication()
    
    var currentSession: Session? {
        if let savedSession = UserDefaults.standard.object(forKey: kSession) as? Data {
            return try? JSONDecoder().decode(Session.self, from: savedSession)
        } else {
            return nil
        }
    }
    
    var credentials: CredentialType {
        return currentSession != nil
            ? .session
            : AccessToken.current != nil
                ? .facebook
                : .none
    }
    
    enum CredentialType {
        case session
        case facebook
        case none
    }
}
