import SwiftUI
import UserNotifications
import Auth0


struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var wantsToGoOut = false
    
    var body: some View {
        ZStack {
            BackgroundGradientView()

            VStack {
                HeaderView(title: "Who you tryna see? ✨")
                FriendsScrollView()
                GoOutButton(wantsToGoOut: $wantsToGoOut) {
                    scheduleNotification()
                }
            }
        }
    }

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

struct BackgroundGradientView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct HeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .shadow(radius: 10)
    }
}

struct FriendsScrollView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(authViewModel.friends) { friend in
                    FriendCircleView(friend: friend.id, isSelected: authViewModel.selectedFriends.contains(friend.id))
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
    var friend: String
    var isSelected: Bool

    var body: some View {
        Text(String(friend.prefix(5)))
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

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let authViewModel = AuthViewModel(friendsList: ["823491832u4323e213e12323e1", "1234823491832u4323e213e12323e1", "823491832u4323e213e12323e123", "314132823491832u4323e213e12323e1", "1341323823491832u4323e213e12323e1"])
//        ContentView().environmentObject(authViewModel)
//    }
//}
