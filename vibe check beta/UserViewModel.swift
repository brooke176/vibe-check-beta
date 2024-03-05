
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var numberOfFriends = 0

    private var db = Firestore.firestore()
    
    func createUserProfile(userID: String, completion: @escaping (Bool, Error?) -> Void) {
        let userProfile = ["friends": []]
        db.collection("users").document(userID).setData(userProfile) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func addFriend(currentUserID: String, friendUserID: String, completion: @escaping (Bool, Error?) -> Void) {
        let userRef = db.collection("users").document(currentUserID)
        userRef.updateData([
            "friends": FieldValue.arrayUnion([friendUserID])
        ]) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func fetchNumberOfFriends(userID: String, completion: (() -> Void)? = nil) {
        db.collection("users").document(userID).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                completion?()
                return
            }
            let friends = document.data()?["friends"] as? [String] ?? []
            DispatchQueue.main.async {
                self.numberOfFriends = friends.count
                completion?()
            }
        }
    }

}
