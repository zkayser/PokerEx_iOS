import Foundation
@testable import PokerEx

class FakeSessionLogicController: SessionLogicControllerProtocol {

    var wasErrorCallbackInvoked: Bool = false
    var wasCompletionInvoked: Bool = false
    var didFBGraphResponseSucceed: Bool = true
    var sessionData: Data?
    var response: URLResponse?
    var error: Error?
    
    func signIn(username: String?, password: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let username = username, let password = password else {
            wasErrorCallbackInvoked = true
            return
        }
        guard !username.isEmpty && !password.isEmpty else {
            wasErrorCallbackInvoked = true
            return
        }
        
        wasCompletionInvoked = true
        completion(sessionData, response, error)
    }
    
    func facebookSignIn(errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        if (didFBGraphResponseSucceed) {
            wasCompletionInvoked = true
            completion(sessionData, response, error)
        } else {
            wasErrorCallbackInvoked = true
        }
    }
    
    func googleSignIn(email: String?, tokenId: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let _ = email, let _ = tokenId else {
            wasErrorCallbackInvoked = true
            return
        }
        
        wasCompletionInvoked = true
        completion(sessionData, response, error)
    }
    
    func signUp(registration: Registration, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let _ = registration.name, let _ = registration.password else {
            wasErrorCallbackInvoked = true
            return
        }
        
        wasCompletionInvoked = true
        completion(sessionData, response, error)
    }
    
    func mockNetworkResponse(data: Data?, response: URLResponse?, error: Error?) {
        self.sessionData = data
        self.response = response
        self.error = error
    }
    
    func resetMocks() {
        wasErrorCallbackInvoked = false
        wasCompletionInvoked = false
        didFBGraphResponseSucceed = true
        sessionData = nil
        response = nil
        error = nil
    }
}
