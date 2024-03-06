
import SwiftUI
import Auth0
import SimpleKeychain
import JWTDecode

struct Friend: Identifiable {
    var id: String
    var firstName: String
}

class AuthViewModel: ObservableObject {
    @Published var numberOfFriends = 0
    @Published var friends: [Friend] = []
    @Published var selectedFriends: [String] = []
    @Published var userSignedIn = false
    @Published var isAuthenticated = false
    @Published var navigateToContent = false
    @Published var userProfile = Profile.empty
    var inviterName: String?
    
    init() {
        if let loadedProfile = Profile.loadFromUserDefaults() {
            userProfile = loadedProfile
        }
    }

    func acceptInvitation(inviteID: String) {
        userProfile.addFriend(friendId: inviteID)
        userProfile.saveToUserDefaults()
    }

    
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
    
    func updateAndSaveProfile() {
        self.userProfile.saveToUserDefaults()
    }

    func login() {
        Auth0
            .webAuth()
            .start { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print("Login failed with: \(error)")
                    case .success(let credentials):
                        let accessToken = credentials.accessToken
                        let idToken = credentials.idToken
                        self?.isAuthenticated = true
                        self?.userSignedIn = true
                        
                        do {
                            let profile = try Profile.from(idToken: idToken, accessToken: accessToken)
                            self?.userProfile = profile
                            profile.saveToUserDefaults()
                        } catch {
                            print("Failed to initialize user profile: \(error)")
                        }
                    }
                }
            }
    }
        
        func logout() {
            userSignedIn = false
        }
    }
