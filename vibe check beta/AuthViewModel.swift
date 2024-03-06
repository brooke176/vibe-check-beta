
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
        
        func acceptInvitation(inviteID: String) {
            var currentUserID = self.userProfile.id
            updateFriendListForUser(userId: currentUserID, friendId: inviteID)
            updateFriendListForUser(userId: inviteID, friendId: currentUserID)
        }
        
        private func updateFriendListForUser(userId: String, friendId: String) {
            fetchUserMetadata(userId: userId) { [weak self] currentFriendList in
                var updatedFriendList = currentFriendList
                if !updatedFriendList.contains(friendId) {
                    updatedFriendList.append(friendId)
                }
                self?.writeUserMetadata(userId: userId, friendList: updatedFriendList)
            }
        }
        
    private func fetchUserMetadata(userId: String, completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "https://yourbackend.com/user/metadata/fetch/\(userId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(self.userProfile.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let userMetadata = jsonResponse["user_metadata"] as? [String: Any],
                   let friendList = userMetadata["friendList"] as? [String] {
                    DispatchQueue.main.async {
                        completion(friendList)
                    }
                } else {
                    print("Failed to parse user metadata")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
        
    private func writeUserMetadata(userId: String, friendList: [String]) {
        guard let url = URL(string: "https://dev-e86qxmlpu8jkgpw3.com/user/metadata/update/\(userId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(self.userProfile.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["friendList": friendList]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("User metadata updated successfully")
            } else {
                print("Failed to update user metadata")
            }
        }.resume()
    }
    
    func generateInviteLink() -> String {
        let userId = self.userProfile.id
        return "https://testflight.apple.com/join/\(userId)"
    }

    func addFriend(userId: String, friendId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: "https://testflight.apple.com/join/AWthlKxo") else { return }
        // perhaps the invite code will change to the userId
        let body: [String: Any] = ["userId": userId, "friendId": friendId]
        guard let finalBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            let success = true // Replace this with actual success determination based on your response
            DispatchQueue.main.async {
                completion(success, nil)
            }
        }.resume()
    }
    
    func checkAuth0Session(completion: @escaping (Bool) -> Void) {
        let isLoggedIn = self.userSignedIn
        DispatchQueue.main.async {
            self.userSignedIn = isLoggedIn
            completion(isLoggedIn)
        }
    }
    
    func login() {
        Auth0
            .webAuth()
            .start { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print("Login failed with: \(error)")
                    case .success(let credentials):
                        let accessToken = credentials.accessToken
                        let idToken = credentials.idToken

                        self.isAuthenticated = true
                        self.userProfile = Profile.from(idToken, accessToken: accessToken)
                        self.userSignedIn = true
                        
                        do {
                            let currentUserID = try self.extractUserId(from: idToken)
                            self.updateFriendListForUser(userId: currentUserID, friendId: self.inviterName ?? "")
                        } catch {
                            print("Failed to extract user ID: \(error)")
                        }
                    }
                }
            }
    }


    func extractUserId(from idToken: String) throws -> String {
            let jwt = try decode(jwt: idToken)
            if let userId = jwt.claim(name: "sub").string {
                return userId
            } else {
                throw NSError(domain: "AuthViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract user ID."])
            }
        }
        
        func logout() {
            userSignedIn = false
        }
    }
