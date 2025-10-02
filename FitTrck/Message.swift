import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let imageData: Data?
    
    init(content: String, isUser: Bool, imageData: Data? = nil) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.imageData = imageData
    }
}