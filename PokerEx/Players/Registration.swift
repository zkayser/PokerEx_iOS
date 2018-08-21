import Foundation

struct Registration {
    var firstName: String?
    var lastName: String?
    var email: String?
    var name: String?
    var password: String?
    var blurb: String?
    
    enum CodingKeys: String, CodingKey {
        case registration
    }
    
    enum RegistrationKeys: String, CodingKey {
        case firstName
        case lastName
        case email
        case name
        case password
        case blurb
    }
}

extension Registration: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var registrationInfo = container.nestedContainer(keyedBy: RegistrationKeys.self, forKey: .registration)
        try registrationInfo.encode(firstName, forKey: .firstName)
        try registrationInfo.encode(lastName, forKey: .lastName)
        try registrationInfo.encode(email, forKey: .email)
        try registrationInfo.encode(name, forKey: .name)
        try registrationInfo.encode(password, forKey: .password)
        try registrationInfo.encode(blurb, forKey: .blurb)
    }
}
