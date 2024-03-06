import Foundation
import JWTDecode

struct Profile: Codable {
    var id: String
    var name: String
    var email: String
    var emailVerified: Bool
    var picture: String
    var updatedAt: String
    var friendList: [String]
    
    static var empty: Self {
        return Profile(id: "", name: "", email: "", emailVerified: false, picture: "", updatedAt: "", friendList: [])
    }

    mutating func addFriend(friendId: String) {
        guard !friendList.contains(friendId) else { return }
        friendList.append(friendId)
        saveToUserDefaults()
    }

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserProfile")
        }
    }

    static func loadFromUserDefaults() -> Profile? {
        if let savedProfile = UserDefaults.standard.object(forKey: "UserProfile") as? Data {
            return try? JSONDecoder().decode(Profile.self, from: savedProfile)
        }
        return nil
    }

    static func from(idToken: String, accessToken: String) throws -> Self {
        let jwt = try decode(jwt: idToken)
        guard let id = jwt.subject else {
            throw NSError(domain: "Profile", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found in token."])
        }
        let name = jwt.claim(name: "name").string ?? ""
        let email = jwt.claim(name: "email").string ?? ""
        let emailVerified = jwt.claim(name: "email_verified").boolean ?? false
        let picture = jwt.claim(name: "picture").string ?? ""
        let updatedAt = jwt.claim(name: "updated_at").string ?? ""
        
        let friendList = [String]()
        
        return Profile(
            id: id,
            name: name,
            email: email,
            emailVerified: emailVerified,
            picture: picture,
            updatedAt: updatedAt,
            friendList: friendList
        )
    }
    
    
}
