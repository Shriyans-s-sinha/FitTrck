import SwiftUI
import PhotosUI

struct ChatView: View {
    @StateObject private var openAIService = OpenAIService()
    @StateObject private var conversationManager = ConversationManager()
    @StateObject private var userProfile = UserProfile()
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var isAnalyzing = false
    @State private var selectedImage: UIImage?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var showingProfile = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(conversationManager.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("FitTrck is thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .contentShape(Rectangle())
                .onChange(of: conversationManager.messages.count) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        if let lastMessage = conversationManager.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        if let lastMessage = conversationManager.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Selected Image Preview
            if let selectedImage = selectedImage {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Selected Image")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Remove") {
                            withAnimation(.spring()) {
                                self.selectedImage = nil
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 120)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Input Area
            VStack(spacing: 12) {
                Divider()
                
                HStack(alignment: .bottom, spacing: 12) {
                    // Camera/Photo buttons
                    Menu {
                        Button(action: { showingCamera = true }) {
                            Label("Take Photo", systemImage: "camera")
                        }
                        Button(action: { showingImagePicker = true }) {
                            Label("Choose from Library", systemImage: "photo")
                        }
                    } label: {
                        Image(systemName: selectedImage != nil ? "photo.fill" : "camera")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .frame(width: 44, height: 44)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(isLoading)
                    
                    // Text Input
                    HStack(alignment: .bottom, spacing: 8) {
                        TextField("Ask about nutrition, recipes, or share a photo...", text: $messageText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(1...4)
                            .disabled(isLoading)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(canSendMessage ? .accentColor : .gray)
                        }
                        .disabled(!canSendMessage || isLoading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("FitTrck")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingProfile = true
                }) {
                    Image(systemName: userProfile.isProfileComplete() ? "person.circle.fill" : "person.circle")
                        .foregroundColor(userProfile.isProfileComplete() ? .green : .gray)
                        .font(.title2)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Clear Conversation") {
                        withAnimation(.easeInOut) {
                            conversationManager.clearMessages()
                        }
                    }
                    Button("Export Chat") {
                        // TODO: Implement export functionality
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileSetupView(userProfile: userProfile)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView(selectedImage: $selectedImage, isAnalyzing: $isAnalyzing)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .onAppear {
            conversationManager.loadMessages()
        }
    }
    
    private var canSendMessage: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || selectedImage != nil else { return }
        
        let userMessage = Message(
            content: text.isEmpty ? "Please analyze this image" : text,
            isUser: true,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8)
        )
        
        conversationManager.addMessage(userMessage)
        
        let currentText = text
        let currentImage = selectedImage
        
        messageText = ""
        selectedImage = nil
        isLoading = true
        
        Task {
            do {
                let contextualMessage = userProfile.isProfileComplete() ? 
                    "\(userProfile.getContextString())\n\nUser message: \(currentText.isEmpty ? "Please analyze this image for nutritional content and suggest meals I can make." : currentText)" : (currentText.isEmpty ? "Please analyze this image for nutritional content and suggest meals I can make." : currentText)
                
                let response = try await openAIService.sendMessage(contextualMessage, with: currentImage)
                
                await MainActor.run {
                    let aiMessage = Message(content: response, isUser: false)
                    conversationManager.addMessage(aiMessage)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isLoading = false
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 200, maxHeight: 200)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                if !message.content.isEmpty {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(message.isUser ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(message.isUser ? Color.accentColor : Color(.systemGray5))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: message.id)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

// Removed duplicate CameraView declaration from ChatView; using unified CameraView from PantryView.

#Preview {
    NavigationView {
        ChatView()
            .navigationTitle("FitTrck")
    }
}