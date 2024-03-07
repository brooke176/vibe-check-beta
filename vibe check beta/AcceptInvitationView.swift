import SwiftUI
import Auth0

struct AcceptInvitationView: View {
    let inviterUserID: String
    @State private var hasAccepted: Bool?
    @State private var showingContentView = false
    @State var invitedName: String = "Brooke"
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var userProfile = Profile.empty

    var body: some View {
        ZStack {
            NavigationLink(destination: ContentView().environmentObject(authViewModel), isActive: $authViewModel.navigateToContent) {
                EmptyView()
            }
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("🎉 You've got a vibe check from \(invitedName)! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                
                Text("Enter your name below and press accept if you would like to accept \(invitedName)'s invitation to connect.")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                
                TextField("Your Name", text: $invitedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack(spacing: 40) {
                    Button("Accept") {
//                        authViewModel.acceptInvitation(inviteID: inviterUserID)
                    }
                    .buttonStyle(SleekButtonStyle(backgroundColor: Color.green))
                    
                    Button("Decline") {
                        print("nvm")
                    }
                    .buttonStyle(SleekButtonStyle(backgroundColor: Color.red))
                }
                .padding(.bottom, 50)
                
                Spacer()
            }
        }
    }
    }

struct SleekButtonStyle: ButtonStyle {
    var backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(radius: 10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut, value: configuration.isPressed)
    }
}

struct AcceptInvitationView_Previews: PreviewProvider {
    static var previews: some View {
        let inviterUserID: String = "Brooke"
        AcceptInvitationView(inviterUserID: inviterUserID)
    }
}
