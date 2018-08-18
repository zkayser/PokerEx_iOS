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
    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    var currentSession: Session? {
        if let savedSession = userDefaults.object(forKey: kSession) as? Data {
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
            userDefaults.removeObject(forKey: kSession)
        }
    }
}
