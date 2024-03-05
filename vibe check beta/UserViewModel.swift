
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var numberOfFriends = 0

    private var db = Firestore.firestore()

    func fetchNumberOfFriends(userID: String) {
        db.collection("users").document(userID).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            let friends = document.data()?["friends"] as? [String] ?? []
            DispatchQueue.main.async {
                self.numberOfFriends = friends.count
            }
        }
    }
}
