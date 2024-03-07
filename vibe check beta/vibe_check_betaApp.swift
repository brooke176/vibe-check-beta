import SwiftUI
import Auth0
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

@main
struct VibeCheckBetaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    @State private var activeLink: ActiveLink? = nil
    @Environment(\.scenePhase) private var scenePhase
    
    enum ActiveLink {
        case acceptInvitation(inviterUserID: String), main
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear {
                    checkUserState()
                }
                .onChange(of: scenePhase) { _ in
                    checkUserState()
                }
        }
    }
    
    func checkUserState() {
        authViewModel.checkAuth0Session { isAuthenticated in
            if isAuthenticated {
                if let activeLink = activeLink, case let .acceptInvitation(inviteID) = activeLink {
                    acceptInvitation(inviteID: inviteID)
                } else {
                    self.activeLink = .main
                }
            } else {
                self.activeLink = nil
            }
        }
    }

    func acceptInvitation(inviteID: String) {
        self.activeLink = .acceptInvitation(inviterUserID: inviteID)
    }
}
