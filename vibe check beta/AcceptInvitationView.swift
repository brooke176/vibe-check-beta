import SwiftUI
import Foundation

class NetworkManager {
    static let shared = NetworkManager()

    private var friendsList: [String] = []

    func addFriend(name: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.friendsList.append(name)
            completion(true)
        }
    }

    func fetchNumberOfFriends(completion: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(self.friendsList.count)
        }
    }
}

struct AcceptInvitationView: View {
    let inviterName: String
    @State private var hasAccepted: Bool?
    @State private var showingContentView = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 You've got a vibe check from \(inviterName)! 🎉")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Do you want to accept \(inviterName)'s invitation to connect?")
                .font(.headline)
                .padding()
            
            HStack(spacing: 40) {
                Button("Accept") {
                    acceptInvitation(accepted: true)
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .green))
                
                Button("Decline") {
                    acceptInvitation(accepted: false)
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .red))
            }
            .padding()
            
            NavigationLink(destination: ContentView(), isActive: $showingContentView) { EmptyView() }
        }
    }
    
    func acceptInvitation(accepted: Bool) {
        self.hasAccepted = accepted
        
        if accepted {
            NetworkManager.shared.addFriend(name: inviterName) { success in
                DispatchQueue.main.async {
                    if success {
                        self.showingContentView = true
                    } else {
                        print("Failed to add friend.")
                    }
                }
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(backgroundColor)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}


struct AcceptInvitationView_Previews: PreviewProvider {
    static var previews: some View {
        AcceptInvitationView(inviterName: "Jamie")
    }
}

