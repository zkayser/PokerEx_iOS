import XCTest
@testable import PokerEx

fileprivate let FIRST_NAME = "First"
fileprivate let LAST_NAME = "Last"
fileprivate let EMAIL = "emaily@mcemailface.com"
fileprivate let USERNAME = "user"
fileprivate let PASSWORD = "password"
fileprivate let BLURB = "This is a blurb about a person"
fileprivate let BUTTON = UIButton()

class SignUpViewControllerTests: XCTestCase {
    
    var signUpViewController = SignUpViewController()
    var fakeSessionLogicController = FakeSessionLogicController()
    let validRegistration = Registration(firstName: FIRST_NAME, lastName: LAST_NAME, email: EMAIL, name: USERNAME, password: PASSWORD, blurb: BLURB)
    let noUsernameRegistration = Registration(firstName: FIRST_NAME, lastName: LAST_NAME, email: EMAIL, name: nil, password: PASSWORD, blurb: BLURB)
    let noPasswordRegistration = Registration(firstName: FIRST_NAME, lastName: LAST_NAME, email: EMAIL, name: USERNAME, password: nil, blurb: BLURB)
    
    let serverResponse = Session(player: Session.SessionPlayer(email: "example@example.com",
                                                        token: "someToken",
                                                        username: "user",
                                                        chips: 1000))
    var sessionData: Data? {
        return try? JSONEncoder().encode(serverResponse)
    }
    let urlResponse = URLResponse(url: URL(string: "www.mock.com")!,
                                  mimeType: nil,
                                  expectedContentLength: 0,
                                  textEncodingName: "utf-8")
    
    let error = MockError.error("Signup failed")
    
    var signUpFailed: Bool = false
    var assignedDataToUserDefaults: Bool = false
    var dataAssignedToUserDefaults: Data?
    lazy var mockSessionCallback: DataTaskCallback = { data, response, error in
        guard let data = data, let response = response, error == nil else {
            self.signUpFailed = true
            return
        }
        
        self.assignedDataToUserDefaults = true
    }
    
    override func setUp() {
        signUpViewController.sessionLogicController = fakeSessionLogicController
        signUpViewController.sessionCallback = mockSessionCallback
    }
    
    override func tearDown() {
        signUpViewController.registration = Registration()
        fakeSessionLogicController.resetMocks()
        signUpFailed = false
        assignedDataToUserDefaults = false
    }
    
    func test_givenValidRegistration_signUpInvokesCallbackWithSuccess() {
        signUpViewController.registration = validRegistration
        fakeSessionLogicController.mockNetworkResponse(data: sessionData, response: urlResponse, error: nil)
        signUpViewController.signUp(BUTTON)
        XCTAssert(fakeSessionLogicController.wasCompletionInvoked)
        XCTAssert(assignedDataToUserDefaults)
    }
    
    func test_givenNoUsername_signUpInvokesRenderErrorCallback() {
        signUpViewController.registration = noUsernameRegistration
        signUpViewController.signUp(BUTTON)
        XCTAssert(fakeSessionLogicController.wasErrorCallbackInvoked)
    }
    
    func test_givenNoPassword_signUpInvokesRenderErrorCallback() {
        signUpViewController.registration = noPasswordRegistration
        signUpViewController.signUp(BUTTON)
        XCTAssert(fakeSessionLogicController.wasErrorCallbackInvoked)
    }
    
    func test_givenFailedApiResponse_sessionCallbackErrorIsInvoked() {
        signUpViewController.registration = validRegistration
        fakeSessionLogicController.mockNetworkResponse(data: nil, response: nil, error: error)
        signUpViewController.signUp(BUTTON)
        XCTAssert(fakeSessionLogicController.wasCompletionInvoked)
        XCTAssert(signUpFailed)
    }
    
}
