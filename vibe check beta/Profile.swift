import Foundation
import JWTDecode

struct Profile: Decodable {
    let id: String
    let name: String
    let email: String
    let emailVerified: String
    let picture: String
    let updatedAt: String
    var friendList: [String]
    
    static var empty: Self {
        return Profile(
            id: "",
            name: "",
            email: "",
            emailVerified: "",
            picture: "",
            updatedAt: "",
            friendList: []
        )
    }
    
    static func loadFromUserDefaults() -> Profile? {
        if let savedProfile = UserDefaults.standard.object(forKey: "UserProfile") as? Data {
            return try? JSONDecoder().decode(Profile.self, from: savedProfile)
        }
        return nil
    }
    
    static func from(_ idToken: String) -> Self {
        guard
            let jwt = try? decode(jwt: idToken),
            let id = jwt.subject,
            let name = jwt.claim(name: "name").string,
            let email = jwt.claim(name: "email").string,
            let emailVerified = jwt.claim(name: "email_verified").boolean,
            let picture = jwt.claim(name: "picture").string,
            let updatedAt = jwt.claim(name: "updated_at").string
        else {
            return .empty
        }
        
        var friendList: [String] = []
        if let friendListClaim = jwt.claim(name: "user_metadata").string,

           let friendListData = try? JSONDecoder().decode([String].self, from: friendListClaim.data(using: .utf8) ?? Data()) {
            friendList = friendListData
        }

        return Profile(
            id: id,
            name: name,
            email: email,
            emailVerified: String(describing: emailVerified),
            picture: picture,
            updatedAt: updatedAt,
            friendList: friendList
        )
    }
}
