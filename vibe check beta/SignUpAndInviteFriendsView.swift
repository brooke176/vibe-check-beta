import SwiftUI
import ContactsUI
import Auth0

struct SignUpAndInviteFriendsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var showingContactPicker = false
    @State private var showingShareSheet = false
    @State var userProfile = Profile.empty
    let testFlightLink = "https://testflight.apple.com/join/AWthlKxo"

    var body: some View {
            ZStack {
                
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
                if authViewModel.userSignedIn {
                    ContentView()
                } else {
                    welcomeAndSignUpSection
                }
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: ["Check out vibe check on TestFlight: \(testFlightLink)"])
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPicker(phoneNumber: .constant(""))
        }
        .onAppear {
            //            checkIfUserSignedIn()
        }
    }
    
    var welcomeAndSignUpSection: some View {
        VStack(spacing: 20) {
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
            //
            //            ZStack {
            //                RoundedRectangle(cornerRadius: 100)
            //                    .fill(Color.white.opacity(0.3))
            //                    .frame(width: 300, height: 50)
            //            }
            //            .padding()
            
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
    
    struct ActivityViewController: UIViewControllerRepresentable {
        var activityItems: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
    
    struct ContactPicker: UIViewControllerRepresentable {
        @Binding var phoneNumber: String
        
        func makeUIViewController(context: Context) -> CNContactPickerViewController {
            let picker = CNContactPickerViewController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, CNContactPickerDelegate {
            var parent: ContactPicker
            
            init(_ parent: ContactPicker) {
                self.parent = parent
            }
            
            func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    parent.phoneNumber = phoneNumber
                }
            }
        }
    }
}

struct SignUpAndInviteFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        @EnvironmentObject var authViewModel: AuthViewModel

        SignUpAndInviteFriendsView().environmentObject(authViewModel)
    }
}
