import Foundation
import SwiftUI

class ConversationManager: ObservableObject {
    @Published var messages: [Message] = []
    private let userDefaults = UserDefaults.standard
    private let messagesKey = "SavedMessages"
    private let maxStoredMessages = 100 // Limit to prevent excessive storage usage
    
    init() {
        loadMessages()
    }
    
    func addMessage(_ message: Message) {
        DispatchQueue.main.async {
            self.messages.append(message)
            self.saveMessages()
        }
    }
    
    func clearMessages() {
        DispatchQueue.main.async {
            self.messages.removeAll()
            self.saveMessages()
        }
    }
    
    func loadMessages() {
        guard let data = userDefaults.data(forKey: messagesKey) else {
            // No saved messages, start with welcome message
            addWelcomeMessage()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let savedMessages = try decoder.decode([Message].self, from: data)
            DispatchQueue.main.async {
                self.messages = savedMessages
                
                // Add welcome message if no messages exist
                if self.messages.isEmpty {
                    self.addWelcomeMessage()
                }
            }
        } catch {
            print("Failed to load messages: \(error)")
            addWelcomeMessage()
        }
    }
    
    private func saveMessages() {
        // Keep only the most recent messages to prevent storage bloat
        let messagesToSave = Array(messages.suffix(maxStoredMessages))
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messagesToSave)
            userDefaults.set(data, forKey: messagesKey)
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = Message(
            content: """
            👋 Welcome to FitTrck! I'm your personal AI nutritionist and kitchen helper.
            
            I can help you with:
            • 📸 Analyzing your pantry/fridge contents from photos
            • 🍽️ Creating personalized meal plans
            • 📊 Tracking nutrition and macros
            • 🥗 Suggesting healthy recipe modifications
            • 🛒 Planning grocery lists and budget-friendly meals
            
            Try taking a photo of your pantry or fridge, or just ask me about nutrition!
            """,
            isUser: false
        )
        
        DispatchQueue.main.async {
            self.messages.append(welcomeMessage)
            self.saveMessages()
        }
    }
    
    func exportConversation() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        var exportText = "FitTrck Conversation Export\n"
        exportText += "Generated: \(formatter.string(from: Date()))\n\n"
        
        for message in messages {
            let sender = message.isUser ? "You" : "FitTrck"
            let timestamp = formatter.string(from: message.timestamp)
            exportText += "[\(timestamp)] \(sender):\n"
            exportText += "\(message.content)\n"
            
            if message.imageData != nil {
                exportText += "[Image attached]\n"
            }
            
            exportText += "\n"
        }
        
        return exportText
    }
    
    func getMessageCount() -> Int {
        return messages.count
    }
    
    func getLastMessageDate() -> Date? {
        return messages.last?.timestamp
    }
}