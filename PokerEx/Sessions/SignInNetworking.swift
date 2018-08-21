import Foundation

fileprivate let PLAYER = "player"
fileprivate let USERNAME = "username"
fileprivate let PASSWORD = "password"
fileprivate let NAME = "name"
fileprivate let FACEBOOK_ID = "facebook_id"

class SignInNetworking {
    
    
    static func buildSignInPayload(username: String, password: String) -> [String: Any] {
        var json = [String: Any]()
        var player = [String: Any]()
        player[USERNAME] = username
        player[PASSWORD] = password
        json[PLAYER] = player
        return json
    }
    
    static func buildFacebookSignInPayload(username: String, facebookId: String) -> [String: Any] {
        var json = [String: Any]()
        json[NAME] = username
        json[FACEBOOK_ID] = facebookId
        return json
    }
    
    static func signInRequest(data: Data, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    static func signUpRequest(data: Data, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
