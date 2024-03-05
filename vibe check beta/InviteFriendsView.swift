import SwiftUI
import ContactsUI
import Firebase

enum InviteStatus {
    case none, sent, accepted
}


struct InviteFriendsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showingContactPicker = false
    @State private var activityItems: [Any]? = nil
    @State private var inviteStatus: InviteStatus = .none
    
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
                            activityItems = ["Join me on Vibe Checker! Download the app here: [App Store Link]"]
                            inviteStatus = .sent
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)

                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Invite Friends")
                    .sheet(isPresented: $showingContactPicker) {
                        ContactPicker(phoneNumber: .constant(""))
                    }
                }
                .background(ActivityView(activityItems: $activityItems))
            }
        }

struct ActivityView: UIViewControllerRepresentable {
    @Binding var activityItems: [Any]?

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let activityItems = activityItems else { return }
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if uiViewController.presentedViewController == nil {
            uiViewController.present(activityController, animated: true) {
                self.activityItems = nil
            }
        }
    }
}

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

