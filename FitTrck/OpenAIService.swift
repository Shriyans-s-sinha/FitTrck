import Foundation
import UIKit
import Network

class OpenAIService: ObservableObject {
    private let apiKey = "YOUR_OPENAI_API_KEY_HERE" // Replace with your actual API key
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = true
    
    init() {
        startNetworkMonitoring()
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    func sendMessage(_ message: String, with image: UIImage? = nil, retryCount: Int = 0) async throws -> String {
        // Check network connectivity
        guard isConnected else {
            throw OpenAIError.networkUnavailable
        }
        
        // Validate API key
        guard !apiKey.isEmpty && apiKey != "YOUR_OPENAI_API_KEY_HERE" else {
            throw OpenAIError.invalidAPIKey
        }
        
        // Validate input
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || image != nil else {
            throw OpenAIError.emptyMessage
        }
        var messages: [[String: Any]] = [
            [
                "role": "system",
                "content": """
                You are FitTrck, a personal AI nutritionist and kitchen helper. You help users with:
                - Analyzing pantry/fridge contents from photos
                - Creating personalized meal plans based on available ingredients
                - Providing nutrition advice and macro tracking
                - Suggesting recipe modifications based on dietary preferences
                - Helping with grocery planning and budget-friendly meals
                
                Always be helpful, encouraging, and focus on practical, actionable advice. When users share photos of their pantry or fridge, analyze the visible ingredients and suggest specific meals they can make.
                """
            ]
        ]
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            messages.append([
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": message
                    ],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64Image)"
                        ]
                    ]
                ]
            ])
        } else {
            messages.append([
                "role": "user",
                "content": message
            ])
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw OpenAIError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        // Handle different HTTP status codes
        switch httpResponse.statusCode {
        case 200:
            break // Success
        case 401:
            throw OpenAIError.invalidAPIKey
        case 429:
            // Rate limit - retry with exponential backoff
            if retryCount < 3 {
                let delay = pow(2.0, Double(retryCount)) // 1s, 2s, 4s
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await sendMessage(message, with: image, retryCount: retryCount + 1)
            } else {
                throw OpenAIError.rateLimited
            }
        case 500...599:
            // Server error - retry once
            if retryCount < 1 {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                return try await sendMessage(message, with: image, retryCount: retryCount + 1)
            } else {
                throw OpenAIError.serverError(httpResponse.statusCode)
            }
        default:
            throw OpenAIError.httpError(httpResponse.statusCode)
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            } else {
                throw OpenAIError.decodingError
            }
        } catch {
            throw OpenAIError.decodingError
        }
    }
}

enum OpenAIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case invalidResponse
    case httpError(Int)
    case decodingError
    case networkUnavailable
    case invalidAPIKey
    case emptyMessage
    case rateLimited
    case serverError(Int)
    case imageTooLarge
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL configuration"
        case .encodingError:
            return "Failed to encode request data"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "Request failed with status code: \(code)"
        case .decodingError:
            return "Failed to decode server response"
        case .networkUnavailable:
            return "No internet connection available. Please check your network and try again."
        case .invalidAPIKey:
            return "Invalid OpenAI API key. Please check your configuration."
        case .emptyMessage:
            return "Please enter a message or select an image"
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .imageTooLarge:
            return "Image is too large. Please select a smaller image."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again"
        case .invalidAPIKey:
            return "Update your OpenAI API key in the app settings"
        case .rateLimited:
            return "Wait a few minutes before sending another message"
        case .serverError:
            return "The issue is on OpenAI's end. Try again in a few minutes"
        case .imageTooLarge:
            return "Try taking a new photo or selecting a smaller image"
        default:
            return "Try again or contact support if the problem persists"
        }
    }
}