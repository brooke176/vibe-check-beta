import SwiftUI
import ContactsUI
import Firebase

enum InviteStatus {
    case none, sent, accepted
}

struct InviteFriendsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var inviteStatus: InviteStatus = .none
    @State private var showingContactPicker = false
    @State private var showingShareSheet = false
    let testFlightLink = "https://testflight.apple.com/join/yourTestFlightCode"

    var body: some View {
        Group {
            switch inviteStatus {
            case .none:
                invitationView
            case .sent:
                Text("Invite sent! 🎉").padding().foregroundColor(.white)
            case .accepted:
                ContentView()
            }
        }
    }

    var invitationView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Pick from Contacts") {
                    showingContactPicker = true
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                
                Button("Send Invitation") {
                    self.showingShareSheet = true
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(8)
                .sheet(isPresented: $showingShareSheet) {
                    ActivityViewController(activityItems: ["Check out Vibe Checker on TestFlight: \(testFlightLink)"])
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Invite Friends")
            .sheet(isPresented: $showingContactPicker) {
                ContactPicker(phoneNumber: .constant(""))
            }
        }
    }
}

// MARK: - ActivityViewController Implementation
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Contact Picker and other struct definitions remain unchanged


// MARK: - Contact Picker Integration
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


struct InviteFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        InviteFriendsView()
    }
}

