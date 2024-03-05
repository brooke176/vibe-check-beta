import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var wantsToGoOut = false
    @State private var selectedFriends: [String] = []
    let friendsList = ["Amanda", "Brooke", "Julia", "Trey", "Joe"]
    @State var numberOfFriends = 0 // Ensure this is declared

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                            Text("Who you tryna see? ✨")
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .shadow(radius: 5)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(friendsList, id: \.self) { friend in
                                        FriendCircleView(friend: friend, isSelected: self.selectedFriends.contains(friend))
                                            .onTapGesture {
                                                self.toggleFriendSelection(friend)
                                            }
                                    }
                                }
                            }
                            .frame(height: 120)
                            .padding(.top, 10)
                            
                            Spacer()
                            Button(action: {
                                withAnimation(.spring()) {
                                    self.wantsToGoOut.toggle()
                                }
                                if wantsToGoOut {
                                    scheduleNotification()
                                }
                            }) {
                                Text(wantsToGoOut ? "🚫 nvm lol" : "✨ Let's Go Out!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(wantsToGoOut ? Color.pink : Color.blue)
                                    .cornerRadius(40)
                                    .shadow(color: .black, radius: 10, x: 0, y: 5)
                                    .scaleEffect(wantsToGoOut ? 1.1 : 1.0)
                            }
                            .padding(.bottom, 50)
                            Spacer()
                        }
                    }
                }
                
                func toggleFriendSelection(_ friend: String) {
                    if let index = selectedFriends.firstIndex(of: friend) {
                        selectedFriends.remove(at: index)
                    } else {
                        selectedFriends.append(friend)
                    }
                }
                
                func scheduleNotification() {
                    let center = UNUserNotificationCenter.current()
                    
                    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
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

            struct FriendCircleView: View {
                var friend: String
                var isSelected: Bool
                
                var body: some View {
                    Text(friend)
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(isSelected ? Color.green : Color.gray.opacity(0.5))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
                        )
                        .animation(.easeInOut, value: isSelected)
                        .fixedSize()
                        .shadow(radius: 3)
                }
            }

            struct ContentView_Previews: PreviewProvider {
                static var previews: some View {
                    ContentView()
                }
            }
