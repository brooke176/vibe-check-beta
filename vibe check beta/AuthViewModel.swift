
import SwiftUI
import Auth0
import SimpleKeychain
import JWTDecode

struct Friend: Identifiable {
    let id: String
}

class AuthViewModel: ObservableObject {
    @Published var numberOfFriends = 0
    @Published var selectedFriends: [String] = []
    @Published var userSignedIn = false
    @Published var isAuthenticated = false
    @Published var navigateToContent = false
    @Published var userProfile = Profile.empty
    var inviterName: String?
    @State private var showingContentView = false

     var friends: [Friend] {
        userProfile.friendList.map { id in
            Friend(id: id)
        }
    }
    
    init() {
        if let loadedProfile = Profile.loadFromUserDefaults() {
            userProfile = loadedProfile
        }
    }

//    func acceptInvitation(inviteID: String) {
//        userProfile.addFriend(friendId: inviteID)
//        userProfile.saveToUserDefaults()
//    }

    
    func generateInviteLink() -> String {
        let userId = self.userProfile.id
        return "https://testflight.apple.com/join/\(userId)"
    }
    
    func checkAuth0Session(completion: @escaping (Bool) -> Void) {
        let isLoggedIn = self.userSignedIn
        DispatchQueue.main.async {
            self.userSignedIn = isLoggedIn
            completion(isLoggedIn)
        }
    }
    
//    func updateAndSaveProfile() {
//        self.userProfile.saveToUserDefaults()
//    }
    }
