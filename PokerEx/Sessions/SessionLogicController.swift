import Foundation
import FacebookCore

typealias DataTaskCallback = (Data?, URLResponse?, Error?) -> Void

protocol SessionLogicControllerProtocol {
    func signIn(username: String?, password: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback)
    func facebookSignIn(errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback)
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
        let json = buildSignInPayload(username: username, password: password)
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else { return }
        
        URLSession.shared.dataTask(with: buildSignInRequest(data: data, url: url), completionHandler: completion).resume()
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
    
    private func fireFacebookSignInRequest(username: String?, facebookId: String?, errorCallback: (() -> Void)?, completion: @escaping DataTaskCallback) {
        guard let username = username, let facebookId = facebookId else {
            errorCallback?()
            return
        }
        
        guard let url = URL(string: "\(baseUrl)api/auth") else { return }
        let json = buildFacebookSignInPayload(username: username, facebookId: facebookId)
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else { return }
        
        URLSession.shared.dataTask(with: buildSignInRequest(data: data, url: url), completionHandler: completion).resume()
    }
    
    private func buildSignInPayload(username: String, password: String) -> [String: Any] {
        var json = [String: Any]()
        var player = [String: Any]()
        player["username"] = username
        player["password"] = password
        json["player"] = player
        return json
    }
    
    private func buildFacebookSignInPayload(username: String, facebookId: String) -> [String: Any] {
        var json = [String: Any]()
        json["name"] = username
        json["facebook_id"] = facebookId
        return json
    }
    
    private func buildSignInRequest(data: Data, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
