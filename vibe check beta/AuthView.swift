
import SwiftUI
import Auth0
import SimpleKeychain
import JWTDecode
import OSLog

struct Friend: Identifiable {
    var id: String
    var name: String
}

class AuthViewModel: ObservableObject {
    @Published var numberOfFriends = 0
    @Published var friends: [Friend] = []
    @Published var selectedFriends: [String] = []
    @Published var userSignedIn = false
    @Published var navigateToContent = false
    @Published var userProfile = Profile.empty
    
    func getJWT(completion: @escaping (String?) -> Void) {
        let headers = ["content-type": "application/x-www-form-urlencoded"]
        
        var postData = "grant_type=client_credentials".data(using: .utf8)!
        postData += "&client_id=G0JwVIswkPpw0JJtHb5y13o7Wm34L26H".data(using: .utf8)!
        postData += ("&client_secret=ddXDgIXcyfhWgTqtYj0Rw8Hn7uW-JpimJINoqWeL9ECT_LIbfBU4gkv_dOQT0p-R".data(using: String.Encoding.utf8)!)
        postData += ("&audience=https://dev-e86qxmlpu8jkgpw3.us.auth0.com/api/v2/".data(using: String.Encoding.utf8)!)
        
        var request = URLRequest(url: URL(string: "https://dev-e86qxmlpu8jkgpw3.us.auth0.com/oauth/token")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error getting JWT: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = jsonResponse["access_token"] as? String {
                    completion(accessToken)
                } else {
                    print("Failed to parse JWT")
                    completion(nil)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        dataTask.resume()
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
                        
                        self?.userProfile = Profile.from(idToken, accessToken: accessToken)
                        self?.userSignedIn = true
                        
                        let currentUserID = try? self?.extractUserId(from: idToken)
                        
                        self?.getUserMetadata(userId: currentUserID ?? "") { [weak self] result in
                            switch result {
                            case .success(let friendList):
                                let friendsList: [Friend] = friendList.map { Friend(id: $0.id, name: $0.name) }
                                self?.setFriendsList(with: friendsList)
                                print("friendsList", friendsList)
                                
                            case .failure(let error):
                                print("Error fetching friends: \(error)")
                            }
                        }
                        
                    }
                }
            }
    }
    
    private func updateFriendListForUser(userId: String, friendId: String, friendName: String, completion: @escaping (Error?) -> Void) {
        getUserMetadata(userId: userId) { result in
            switch result {
            case .success(let currentFriendList):
                var updatedFriendList = currentFriendList
                
                if !updatedFriendList.contains(where: { $0.id == friendId }) {
                    updatedFriendList.append((id: friendId, name: friendName))
                }
                
                let friendListDicts = updatedFriendList.map { ["id": $0.id, "name": $0.name] }
                
                self.writeUserMetadata(userId: userId, friendList: friendListDicts)
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func updateFriendsList() {
        let currentUserID = self.userProfile.id
        getUserMetadata(userId: currentUserID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friendList):
                    let friendsList: [Friend] = friendList.map { Friend(id: $0.id, name: $0.name) }
                    self?.setFriendsList(with: friendsList)
                    print("friendsList", friendsList)
                    
                case .failure(let error):
                    print("Error fetching friends: \(error)")
                }
            }
        }
    }
    
    func writeUserMetadata(userId: String, friendList: [Dictionary<String, String>]) {
        print("friendy", friendList)
        getJWT() { [weak self] token in
            guard let token = token else { return }
            guard let url = URL(string: "https://dev-e86qxmlpu8jkgpw3.us.auth0.com/api/v2/users/\(userId)") else { return }
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json"
            ]
            print("token2", token)
            
            
            let parameters: [String: Any] = [
                "user_metadata": ["friendList": friendList]
            ]
            
            do {
                let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                
                var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                request.httpMethod = "PATCH"
                request.allHTTPHeaderFields = headers
                request.httpBody = postData
                
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error updating user metadata:", error)
                        return
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Response:", httpResponse)
                    }
                }
                dataTask.resume()
            } catch {
                print("JSON serialization error:", error)
            }
        }
    }
    // need to start calling this once dynamic friend adding works
    func setFriendsList(with friendsList: [Friend]) {
        DispatchQueue.main.async {
            self.friends = friendsList
        }
    }
    
    func fetchFriendsData() {
        let fetchedFriends: [Friend] = []
        DispatchQueue.main.async {
            self.setFriendsList(with: fetchedFriends)
        }
    }
    
    func getUserMetadata(userId: String, completion: @escaping (Result<[(id: String, name: String)], Error>) -> Void) {
        getJWT { [weak self] token in
            guard let token = token, let url = URL(string: "https://dev-e86qxmlpu8jkgpw3.us.auth0.com/api/v2/users/\(userId)") else {
                completion(.failure(NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token or URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let session = URLSession.shared
            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "AuthViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let userMetadata = jsonResponse["user_metadata"] as? [String: Any],
                       let friendListData = userMetadata["friendList"] as? [[String: Any]] {
                        let friendList = friendListData.compactMap { friendDict -> (id: String, name: String)? in
                            guard let id = friendDict["id"] as? String, let name = friendDict["name"] as? String else { return nil }
                            return (id: id, name: name)
                        }
                        
                        completion(.success(friendList))
                    } else {
                        completion(.failure(NSError(domain: "AuthViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user metadata"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    func checkAuth0Session(completion: @escaping (Bool) -> Void) {
        let isLoggedIn = self.userSignedIn
        DispatchQueue.main.async {
            self.userSignedIn = isLoggedIn
            completion(isLoggedIn)
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
        Auth0
            .webAuth()
            .clearSession { result in
                switch result {
                case .success:
                    print("Logged out")
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
        userSignedIn = false
    }
    
    func triggerLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Match Found!"
        content.body = "Your friend is ready to go out too!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func getJWTBackend(completion: @escaping (String?) -> Void) {
        let headers = ["content-type": "application/x-www-form-urlencoded"]
        
        var postData = "grant_type=client_credentials".data(using: .utf8)!
        postData += "&client_id=p77IPGDAGeg0XC1xcXy8Ewk8vhZOM0BA".data(using: .utf8)!
        postData += "&client_secret=z5HJu497ceeVuXVZYDQ-xSBBoIALCMdel0KKnW1LRCndVNzEJU7S8EQefBROS0LX".data(using: .utf8)!
        postData += "&audience=https://vcapi.com/api/intent/goOut".data(using: .utf8)!

        var request = URLRequest(url: URL(string: "https://dev-e86qxmlpu8jkgpw3.us.auth0.com/oauth/token")!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData
        
        let session = URLSession.shared

        let dataTask = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error getting JWT for backend: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("Raw response: \(responseString ?? "N/A")")

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let accessToken = jsonResponse["access_token"] as? String {
                        completion(accessToken)
                    } else if let error = jsonResponse["error"] as? String, let errorDescription = jsonResponse["error_description"] as? String {
                        print("Error from Auth0: \(error), Description: \(errorDescription)")
                        completion(nil)
                    }
                } else {
                    print("Failed to parse JWT for backend")
                    completion(nil)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                completion(nil)
            }
        }

        dataTask.resume()
    }

}

extension AuthViewModel {
    func sendGoOutIntent(selectedFriends: [String], wantsToGoOut: Bool) {
        getJWTBackend { [weak self] token in
            guard let token = token, let userId = self?.userProfile.id else { return }
            print("tokentest", token)
            let url = URL(string: "http://10.173.205.220:8080/api/intent/goOut")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody: [String: Any] = [
                "userId": userId,
                "wantsToGoOut": wantsToGoOut,
                "selectedFriends": selectedFriends
            ]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
                request.httpBody = jsonData
                
                let session = URLSession.shared
                let task = session.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error sending go out intent: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    let decoder = JSONDecoder()
                    if let mutualIntentResponse = try? decoder.decode(MutualIntentResponse.self, from: data),
                       mutualIntentResponse.mutual {
                        DispatchQueue.main.async {
                            self?.triggerLocalNotification()
                        }
                    }
                }
                task.resume()
            } catch {
                print("Error serializing JSON: \(error.localizedDescription)")
            }
            print("token", token)
        }
    }

}
