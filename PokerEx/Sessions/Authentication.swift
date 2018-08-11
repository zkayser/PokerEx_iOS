import Foundation

class Authentication {
    var currentUser: String?
    
    static var shared: Authentication = Authentication(currentUser: nil)
    
    init(currentUser: String?) {
        self.currentUser = currentUser
    }
    
    
}
