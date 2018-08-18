import Foundation
@testable import PokerEx

class FakeSessionLogicController: SessionLogicControllerProtocol {
    var wasErrorCallbackInvoked: Bool = false
    var wasCompletionInvoked: Bool = false
    var didFBGraphResponseSucceed: Bool = true
    let session = Session(player:
        Session.SessionPlayer(email: "example@example.com",
                              token: "someToken",
                              username: "user",
                              chips: 1000))
    var sessionData: Data?
    var response: URLResponse?
    var error: Error?
    
    func signIn(username: String?, password: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let _ = username, let _ = password else {
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
