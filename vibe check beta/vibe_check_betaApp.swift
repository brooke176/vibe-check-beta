import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct vibe_check_betaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userViewModel = UserViewModel()
    @State private var showingAcceptInvitationView = false
    @State private var inviteID: String? = nil
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if showingAcceptInvitationView, let inviteID = inviteID {
                    AcceptInvitationView(inviterName: inviteID)
                } else if userViewModel.numberOfFriends > 0 {
                    ContentView().environmentObject(userViewModel)
                } else {
                    InviteFriendsView().environmentObject(userViewModel)
                }
            }
            .onAppear {
                let userID = "currentUserID"
                userViewModel.fetchNumberOfFriends(userID: userID)
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }

    func handleDeepLink(_ url: URL) {
        if url.pathComponents.contains("invite"), let lastComponent = url.pathComponents.last {
            inviteID = lastComponent
            showingAcceptInvitationView = true
        }
    }
}
