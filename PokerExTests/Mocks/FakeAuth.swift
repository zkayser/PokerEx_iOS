import Foundation
@testable import PokerEx

class FakeAuth: AuthenticationProtocol {
    
    var credentials: CredentialType = .none
    
    func getCredentials() -> CredentialType {
        return credentials
    }
}
