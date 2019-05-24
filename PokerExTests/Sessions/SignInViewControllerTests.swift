import XCTest
@testable import PokerEx
import GoogleSignIn

class SignInViewControllerTests: XCTestCase {
    
    var signInViewController = SignInViewController()
    var auth = FakeAuth()
    var fakeSessionLogicController = FakeSessionLogicController()
    let session = Session(player: Session.SessionPlayer(email: "example@example.com",
                                                        token: "someToken",
                                                        username: "user",
                                                        chips: 1000))
    
    /**
     Set up sessionData, urlResponse, and error response to be passed to
     the SignInViewController instance's signInCallback. These values
     should be set as properties on the fakeSessionLogicController which
     in turn will invoke the signInViewController's signInCallback with
     them. 
     */
    var sessionData: Data? {
        return try? JSONEncoder().encode(session)
    }
    
    let urlResponse = URLResponse(url: URL(string: "www.mock.com")!,
                                  mimeType: nil,
                                  expectedContentLength: 0,
                                  textEncodingName: "utf-8")
    
    let error = MockError.error("Login failed")
    
    var signInFailed: Bool = false
    var assignedDataToUserDefaults: Bool = false
    var dataAssignedToUserDefaults: Data?
    lazy var mockSessionCallback: DataTaskCallback = { data, response, error in
        guard let data = data, let response = response, error == nil else {
            self.signInFailed = true
            return
        }
        
        self.assignedDataToUserDefaults = true
        self.dataAssignedToUserDefaults = data
    }
    
    override func setUp() {
        signInViewController.authentication = auth
        signInViewController.sessionLogicController = fakeSessionLogicController
        signInViewController.sessionCallback = mockSessionCallback
    }
    
    override func tearDown() {
        signInViewController.password = nil
        signInViewController.username = nil
        fakeSessionLogicController.resetMocks()
        auth.credentials = .none
        signInFailed = false
        assignedDataToUserDefaults = false
        dataAssignedToUserDefaults = nil
    }
    
    func test_givenFacebookCredentials_viewWillAppearCallsFBLogin() {
        auth.credentials = .facebook
        // Mock successful network response
        fakeSessionLogicController.mockNetworkResponse(data: sessionData, response: urlResponse, error: nil)
        fakeSessionLogicController.didFBGraphResponseSucceed = true
        signInViewController.viewWillAppear(false)
        XCTAssert(fakeSessionLogicController.wasCompletionInvoked)
        XCTAssert(assignedDataToUserDefaults)
        XCTAssertEqual(dataAssignedToUserDefaults, sessionData)
    }
    
    func test_givenFailureOnFacebookOAuthRequest_viewWillAppearCallsErrorCallback() {
        auth.credentials = .facebook
        // Mock unsuccessful network response
        fakeSessionLogicController.mockNetworkResponse(data: nil, response: nil, error: error)
        fakeSessionLogicController.didFBGraphResponseSucceed = true
        signInViewController.viewWillAppear(false)
        XCTAssert(fakeSessionLogicController.wasCompletionInvoked)
        XCTAssert(signInFailed)
    }
    
    func test_givenFacebookGraphRequestFailure_viewWillAppearInvokesFBErrorCallback() {
        auth.credentials = .facebook
        fakeSessionLogicController.didFBGraphResponseSucceed = false
        signInViewController.viewWillAppear(false)
        XCTAssert(fakeSessionLogicController.wasErrorCallbackInvoked)
        XCTAssertFalse(fakeSessionLogicController.wasCompletionInvoked)
    }
    
    func test_givenUsernameAndPasswordWithSuccessfulAPIResponse_signInInvokesCallbackWithSuccess() {
        signInViewController.username = "someUser"
        signInViewController.password = "password"
        // Mock successful network response
        fakeSessionLogicController.mockNetworkResponse(data: sessionData, response: urlResponse, error: nil)
        signInViewController.signIn(UIButton())
        XCTAssert(fakeSessionLogicController.wasCompletionInvoked)
        XCTAssertEqual(dataAssignedToUserDefaults, sessionData)
        XCTAssert(assignedDataToUserDefaults)
    }
    
    func test_givenEmptyUsernameOrPassword_signInInvokesErrorCallback() {
        signInViewController.signIn(UIButton())
        XCTAssert(fakeSessionLogicController.wasErrorCallbackInvoked)
    }
    
    func test_givenErrorOnAPISignin_signInInvokesCallbackWithError() {
        signInViewController.username = "someUser"
        signInViewController.password = "password"
        // Mock unsuccessful network response
        fakeSessionLogicController.mockNetworkResponse(data: nil, response: nil, error: error)
        signInViewController.signIn(UIButton())
        XCTAssert(fakeSessionLogicController.wasCompletionInvoked)
        XCTAssert(signInFailed)
    }
}
