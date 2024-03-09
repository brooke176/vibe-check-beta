import SwiftUI
import UserNotifications
import Auth0
import ContactsUI
import OSLog

struct ContentView: View {
    @State private var wantsToGoOut = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var webSocketManager = WebSocketManager()
    @State private var showingContactPicker = false
    @State private var showingShareSheet = false
    let testFlightLink = "https://testflight.apple.com/join/AWthlKxo"
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            
            VStack {
                HeaderView(title: "Who you tryna see? ✨")
                FriendsScrollView()
                GoOutButton(wantsToGoOut: $wantsToGoOut)
                
                Button("Log out") {
                    authViewModel.logout()
                }
                .foregroundColor(.white)
                .padding()
                .background(Capsule().fill(Color.green))
                .shadow(radius: 5)
            }
        }
        .onAppear {
            let userId = authViewModel.userProfile.id
            if !userId.isEmpty { // Check if userId is not empty
                webSocketManager.connect(userId: userId)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: ["Check out vibe check on TestFlight: \(testFlightLink)"])
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPicker(phoneNumber: .constant(""))
        }
        }
    
    var inviteFriendsSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("invite besties <3")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Button(action: { showingContactPicker = true }) {
                Text("Pick from Contacts")
                    .foregroundColor(.white)
                    .padding()
                    .background(Capsule().fill(Color.blue))
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            
            Button(action: { showingShareSheet = true }) {
                Text("Send TestFlight Invitation")
                    .foregroundColor(.white)
                    .padding()
                    .background(Capsule().fill(Color.green))
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct FriendsScrollView: View {
    func loadFriends() {
         authViewModel.fetchFriendsData()
        print("friends", authViewModel.friends)
    }
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(authViewModel.friends) { friend in
                    FriendCircleView(friend: friend, isSelected: authViewModel.selectedFriends.contains(friend.id))
                                            .onTapGesture {
                            self.toggleFriendSelection(friend.id)
                        }
                }
            }
            .padding()
        }
        .frame(height: 100)
    }
    
    private func toggleFriendSelection(_ friendID: String) {
        if let index = authViewModel.selectedFriends.firstIndex(of: friendID) {
            authViewModel.selectedFriends.remove(at: index)
        } else {
            authViewModel.selectedFriends.append(friendID)
        }
    }
}

struct FriendCircleView: View {
    var friend: Friend
    var isSelected: Bool

    var body: some View {
        Text(friend.name)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(10)
            .background(isSelected ? Color.green : Color.gray)
            .clipShape(Circle())
            .overlay(Circle().stroke(isSelected ? Color.green : Color.clear, lineWidth: 2))
            .animation(.easeInOut, value: isSelected)
            .shadow(radius: 3)
    }
}

struct GoOutButton: View {
    @Binding var wantsToGoOut: Bool
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Button(action: {
            withAnimation {
                wantsToGoOut.toggle()
                authViewModel.sendGoOutIntent(selectedFriends: authViewModel.selectedFriends, wantsToGoOut: wantsToGoOut)
            }
        }) {
            Text(wantsToGoOut ? "🚫 nvm lol" : "✨ Let's Go Out!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(wantsToGoOut ? Color.red : Color.green)
                .cornerRadius(30)
                .shadow(radius: 5)
        }
        .padding(.bottom, 50)
    }
}

