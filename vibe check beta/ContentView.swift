import SwiftUI
import UserNotifications
import Auth0
import ContactsUI
import OSLog

struct ContentView: View {
    @State private var wantsToGoOut = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingContactPicker = false
    @State private var showingShareSheet = false
    let testFlightLink = "https://testflight.apple.com/join/AWthlKxo"
    
    var body: some View {
        ZStack {
            BackgroundGradientView()
            
                VStack {
                    HeaderView(title: "Who you tryna see? ✨")
                    FriendsScrollView()
                    GoOutButton(wantsToGoOut: $wantsToGoOut) {
                        scheduleNotification()
                    }
                    Button("Log out") {
                        authViewModel.logout()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Capsule().fill(Color.green))
                    .shadow(radius: 5)
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
    
//    func generateInviteLink() -> String {
//        let userId = self.userProfile.id
//        return "https://testflight.apple.com/join/\(userId)"
//    }

    private func scheduleNotification() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Let's Go Out!"
                content.body = "You're ready to go out! Let's see if your friends are too!"
                content.sound = UNNotificationSound.default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                center.add(request)
            }
        }
    }
}

struct FriendsScrollView: View {
    func loadFriends() {
         authViewModel.updateFriendsList()
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
        Text(friend.firstName)
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
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation {
                wantsToGoOut.toggle()
                action()
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
