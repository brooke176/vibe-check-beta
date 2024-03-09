import SwiftUI
import Foundation

struct MutualIntentResponse: Codable {
    var mutual: Bool
}

class WebSocketManager: ObservableObject {
    var webSocketTask: URLSessionWebSocketTask?
    
    func connect(userId: String) {
        guard let url = URL(string: "ws://10.173.205.220:8080/?userId=\(userId)") else { return } // Adjust URL accordingly
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        listenForMessages()
        print("connected to webstocket!")
    }
    
    func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string: \(text)")
                    if text.contains("mutual intent found") {
                        self?.triggerLocalNotification()
                    }
                case .data(let data):
                    print("Received data: \(data)")
                    let decoder = JSONDecoder()
                    if let mutualIntentResponse = try? decoder.decode(MutualIntentResponse.self, from: data), mutualIntentResponse.mutual {
                        self?.triggerLocalNotification()
                    }
                @unknown default:
                    fatalError("Received an unknown type of message")
                }
                self?.listenForMessages()
            }
        }
    }
    
    func triggerLocalNotification() {
       let content = UNMutableNotificationContent()
       content.title = "Match Found!"
       content.body = "Your friend is ready to go out too!"
       content.sound = .default

       let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
       let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

       UNUserNotificationCenter.current().add(request)
    }
}
