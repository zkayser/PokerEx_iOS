import Foundation

protocol SessionLogicControllerDelegate {
    func renderErrorMessage()
}

typealias DataTaskCallback = (Data?, URLResponse?, Error?) -> Void

class SessionLogicController {
    
    private let baseUrl = NetworkUtils.backendUrl()
    var delegate: SessionLogicControllerDelegate?
    
    func signIn(username: String?, password: String?, completion: @escaping DataTaskCallback) {
        guard let username = username, let password = password else {
            delegate?.renderErrorMessage()
            return
        }
        
        guard let url = URL(string: "\(baseUrl)api/sessions") else { return }
        let json = buildSignInPayload(username: username, password: password)
        
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
    
    private func buildSignInRequest(data: Data, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
