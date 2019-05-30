import XCTest
@testable import PokerEx

class SignInNetworkingTests: XCTestCase {
    
    let username = "someUser"
    let password = "password"
    let facebookId = "someFacebookId"
    let tokenId = "123124121"
    let url = URL(string: "www.mock.com")!
    let data = Data()
    
    func test_itBuildsJSONPayloadsForUsernameAndPasswordCredentials() {
        let json = SignInNetworking.buildSignInPayload(username: username, password: password)
        XCTAssertNotNil(json["player"])
        guard let player = json["player"] as? [String: Any] else {
            XCTFail()
            return
        }
        XCTAssertEqual(player["username"] as! String, username)
        XCTAssertEqual(player["password"] as! String, password)
    }
    
    func test_itBuildsJSONPayloadsForFacebookLoginCredentials() {
        let json = SignInNetworking.buildFacebookSignInPayload(username: username, facebookId: facebookId)
        XCTAssertEqual(json["name"] as! String, username)
        XCTAssertEqual(json["facebook_id"] as! String, facebookId)
    }
    
    func test_itBuildsJSONPayloadsForGoogleLoginCredentials() {
        let json = SignInNetworking.buildGoogleSignInPayload(email: "\(username)@gmail.com", tokenId: tokenId)
        XCTAssertEqual(json["email"] as! String, "\(username)@gmail.com")
        XCTAssertEqual(json["google_token_id"] as! String, tokenId)
    }
    
    func test_itBuildsNetworkRequests() {
        let request = SignInNetworking.sessionRequest(data: data, url: url)
        XCTAssertEqual(request.httpBody, data)
        XCTAssertEqual(request.httpMethod, "POST")
    }
}
