import Foundation
import FacebookCore

enum CredentialType {
    case session
    case facebook
    case none
}

protocol AuthenticationProtocol {
    func getCredentials() -> CredentialType
}

class Authentication: AuthenticationProtocol {
    
    static var shared: Authentication = Authentication()
    
    var currentSession: Session? {
        if let savedSession = UserDefaults.standard.object(forKey: kSession) as? Data {
            return try? JSONDecoder().decode(Session.self, from: savedSession)
        } else {
            return nil
        }
    }
    
    func getCredentials() -> CredentialType {
        return currentSession != nil
            ? .session
            : AccessToken.current != nil
            ? .facebook
            : .none
    }
    
    func logout() {
        if (currentSession != nil) {
            UserDefaults.standard.removeObject(forKey: kSession)
        }
    }
}
