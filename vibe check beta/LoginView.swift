import SwiftUI
import ContactsUI
import Auth0

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    
    var body: some View {
        ZStack {
            Spacer()
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            logInSection
        }
        }
    
    var logInSection: some View {
        VStack() {
                Spacer()
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                Text("feel the vibes")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Button("Continue") {
                    authViewModel.login()
                }
                .foregroundColor(.white)
                .padding()
                .background(Capsule().fill(Color.green))
                .shadow(radius: 5)
                
                Spacer()
        }
    }
    
    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            @EnvironmentObject var authViewModel: AuthViewModel
            
            LoginView().environmentObject(authViewModel)
        }
    }
}
