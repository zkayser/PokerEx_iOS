import Foundation

class NetworkUtils {
    
    static func backendUrl() -> String {
        return (Bundle.main.infoDictionary?["ServerUrl"] as? String) ?? ""
    }
}
