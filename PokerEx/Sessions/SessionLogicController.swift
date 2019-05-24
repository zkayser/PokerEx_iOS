import Foundation
import FacebookCore

typealias DataTaskCallback = (Data?, URLResponse?, Error?) -> Void

protocol SessionDelegateProtocol {
    var sessionCallback: DataTaskCallback { mutating get }
}

protocol SessionLogicControllerProtocol {
    func signIn(username: String?, password: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback)
    func signUp(registration: Registration, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback)
    func facebookSignIn(errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback)
    func googleSignIn(email: String?, tokenId: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback)
}

class SessionLogicController: SessionLogicControllerProtocol {
    
    static let shared = SessionLogicController()
    
    private let baseUrl = NetworkUtils.backendUrl()
    
    func signIn(username: String?, password: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let username = username, let password = password else {
            errorCallback?()
            return
        }
        
        guard let url = URL(string: "\(baseUrl)api/sessions") else { return }
        let json = SignInNetworking.buildSignInPayload(username: username, password: password)
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else { return }
        
        URLSession.shared.dataTask(with: SignInNetworking.sessionRequest(data: data, url: url), completionHandler: completion).resume()
    }
    
    func signUp(registration: Registration, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let _ = registration.name, let _ = registration.password else {
            errorCallback?()
            return
        }
        
        guard let url = URL(string: "\(baseUrl)api/registrations") else { return }
        guard let jsonData = try? JSONEncoder().encode(registration) else {
            errorCallback?()
            return
        }
        
        URLSession.shared.dataTask(with: SignInNetworking.sessionRequest(data: jsonData, url: url), completionHandler: completion).resume()
    }
    
    func facebookSignIn(errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        GraphRequest(graphPath: "me").start { response, result in
            switch (result) {
            case .success(let graphResponse):
                self.fireFacebookSignInRequest(username: (graphResponse.dictionaryValue?["name"] as? String),
                                          facebookId: (graphResponse.dictionaryValue?["id"] as? String),
                                          errorCallback: errorCallback,
                                          completion: completion
                                         )
                default: errorCallback?()
            }
        }
    }
    
    func googleSignIn(email: String?, tokenId: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let email = email, let tokenId = tokenId else {
            errorCallback?()
            return
        }
        
        guard let url = URL(string: "\(baseUrl)api/auth") else { return }
        let json = SignInNetworking.buildGoogleSignInPayload(email: email, tokenId: tokenId)
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else { return }
        
        URLSession.shared.dataTask(with: SignInNetworking.sessionRequest(data: data, url: url), completionHandler: completion).resume()
    }
    
    private func fireFacebookSignInRequest(username: String?, facebookId: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let username = username, let facebookId = facebookId else {
            errorCallback?()
            return
        }
        
        guard let url = URL(string: "\(baseUrl)api/auth") else { return }
        let json = SignInNetworking.buildFacebookSignInPayload(username: username, facebookId: facebookId)
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else { return }
        
        URLSession.shared.dataTask(with: SignInNetworking.sessionRequest(data: data, url: url), completionHandler: completion).resume()
    }
}
