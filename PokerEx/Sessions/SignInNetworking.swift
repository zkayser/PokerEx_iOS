import Foundation

fileprivate let PLAYER = "player"
fileprivate let USERNAME = "username"
fileprivate let PASSWORD = "password"
fileprivate let NAME = "name"
fileprivate let FACEBOOK_ID = "facebook_id"
fileprivate let EMAIL = "email"
fileprivate let TOKEN_ID = "google_token_id"

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
    
    static func buildGoogleSignInPayload(email: String, tokenId: String) -> [String: Any] {
        var json = [String: Any]()
        json[EMAIL] = email
        json[TOKEN_ID] = tokenId
        return json
    }
    
    static func sessionRequest(data: Data, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTP_POST
        request.httpBody = data
        request.addValue(APPLICATION_JSON, forHTTPHeaderField: CONTENT_TYPE)
        request.addValue(APPLICATION_JSON, forHTTPHeaderField: ACCEPT)
        return request
    }
}
