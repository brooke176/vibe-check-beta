import SwiftUI
import FirebaseCore
import FirebaseAuth
import Combine

@main
struct VibeCheckBetaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userViewModel = UserViewModel()
    @State private var activeLink: ActiveLink? = nil
    @Environment(\.scenePhase) private var scenePhase
    private var cancellables: Set<AnyCancellable> = []

    enum ActiveLink {
        case acceptInvitation(String), main
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                switch activeLink {
                case .acceptInvitation(let inviteID):
                    AcceptInvitationView(inviterName: inviteID)
                case .main, .none:
                    if userViewModel.numberOfFriends > 0 {
                        ContentView().environmentObject(userViewModel)
                    } else {
                        InviteFriendsView().environmentObject(userViewModel)
                    }
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkUserState()
            }
        }
    }
    
    private func checkUserState() {
        Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                let userID = user.uid
                self.userViewModel.fetchNumberOfFriends(userID: userID) {
                    // Decide to show main content or invite friends based on the friend count
                    self.activeLink = self.activeLink ?? .main
                }
            } else {
                // No user signed in, consider showing a sign-in view or handling accordingly
            }
        }
    }
}
