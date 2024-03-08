import SwiftUI
import OSLog

@main
struct vibe_check_betaApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @State private var inviterID: String? = nil
    @State private var showingAcceptInvitationView = false
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.userSignedIn {
                ContentView().environmentObject(authViewModel)
            } else {
                LoginView().environmentObject(authViewModel)
            }
        }
    }
    
    //once its in app store
    
    //    var body: some Scene {
    //        WindowGroup {
    //            NavigationView {
    //                if showingAcceptInvitationView, let inviterID = inviterID {
    //                    AcceptInvitationView(inviterUserID: inviterID, invitedName: inviterID)
    //                } else {
    //                    ContentView().environmentObject(authViewModel)
    //                }
    //            }
    //            .onOpenURL { url in
    //                handleDeepLink(url)
    //            }
    //        }
    //    }
    
    //    func handleDeepLink(_ url: URL) {
    //        if url.pathComponents.contains("invite"), let lastComponent = url.pathComponents.last {
    //            inviterID = lastComponent
    //            showingAcceptInvitationView = true
    //        }
    //    }
}

extension Logger {
    private static var subsystem = "vibe"
    static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
    static let statistics = Logger(subsystem: subsystem, category: "statistics")
}
