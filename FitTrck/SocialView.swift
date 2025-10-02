import SwiftUI

struct SocialView: View {
    @State private var selectedTab: SocialTab = .feed
    @State private var showingCreatePost = false
    @State private var showingChallengeDetail = false
    @State private var selectedChallenge: Challenge?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("FitTrck Social")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Share your food journey")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { showingCreatePost = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    // Quick Stats
                    QuickStatsBar()
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Tab Selector
                SocialTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .background(Color(.systemGroupedBackground))
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .feed:
                            FeedContent()
                        case .challenges:
                            ChallengesContent(onChallengeTap: { challenge in
                                selectedChallenge = challenge
                                showingChallengeDetail = true
                            })
                        case .friends:
                            FriendsContent()
                        case .playlists:
                            PlaylistsContent()
                        }
                    }
                    .padding()
                }
                .contentShape(Rectangle())
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView()
        }
        .sheet(isPresented: $showingChallengeDetail) {
            if let challenge = selectedChallenge {
                ChallengeDetailView(challenge: challenge)
            }
        }
    }
}

// MARK: - Quick Stats Bar
struct QuickStatsBar: View {
    var body: some View {
        HStack(spacing: 20) {
            StatItem(title: "Streak", value: "12", subtitle: "days", color: .orange)
            StatItem(title: "Friends", value: "24", subtitle: "active", color: .blue)
            StatItem(title: "Challenges", value: "3", subtitle: "joined", color: .green)
            StatItem(title: "Shared", value: "8", subtitle: "meals", color: .purple)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Social Tab Selector
struct SocialTabSelector: View {
    @Binding var selectedTab: SocialTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SocialTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? Color.accentColor : Color.clear)
                    .cornerRadius(12)
                }
            }
        }
        .padding(4)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Feed Content
struct FeedContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // Stories
            StoriesSection()
            
            // Posts
            ForEach(samplePosts, id: \.id) { post in
                FeedPostCard(post: post)
            }
        }
    }
}

// MARK: - Stories Section
struct StoriesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stories")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Add your story
                    AddStoryButton()
                    
                    // Friend stories
                    ForEach(sampleStories, id: \.id) { story in
                        StoryItem(story: story)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Add Story Button
struct AddStoryButton: View {
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [5]))
                        )
                    
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                
                Text("Your Story")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Story Item
struct StoryItem: View {
    let story: Story
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(story.color.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(story.hasViewed ? Color.gray : story.color, lineWidth: 2)
                        )
                    
                    Text(story.user.initials)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(story.color)
                }
                
                Text(story.user.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feed Post Card
struct FeedPostCard: View {
    let post: FeedPost
    @State private var isLiked = false
    @State private var isSaved = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Circle()
                    .fill(post.user.color.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(post.user.initials)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(post.user.color)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                if !post.caption.isEmpty {
                    Text(post.caption)
                        .font(.subheadline)
                }
                
                // Meal image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(post.mealType.color.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(post.mealType.color)
                            
                            Text(post.mealName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    )
                
                // Meal details
                HStack(spacing: 16) {
                    MealDetailChip(icon: "clock", text: "\(post.cookTime)m", color: .blue)
                    MealDetailChip(icon: "flame.fill", text: "\(post.calories) cal", color: .orange)
                    MealDetailChip(icon: "star.fill", text: String(format: "%.1f", post.rating), color: .yellow)
                }
            }
            
            // Actions
            HStack(spacing: 20) {
                Button(action: { isLiked.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .primary)
                        Text("\(post.likes + (isLiked ? 1 : 0))")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "message")
                            .foregroundColor(.primary)
                        Text("\(post.comments)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: { isSaved.toggle() }) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isSaved ? .accentColor : .primary)
                }
            }
            .font(.title3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Meal Detail Chip
struct MealDetailChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Challenges Content
struct ChallengesContent: View {
    let onChallengeTap: (Challenge) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Active Challenges
            ActiveChallengesCard(onChallengeTap: onChallengeTap)
            
            // Available Challenges
            AvailableChallengesCard(onChallengeTap: onChallengeTap)
            
            // Create Challenge
            CreateChallengeCard()
        }
    }
}

// MARK: - Active Challenges Card
struct ActiveChallengesCard: View {
    let onChallengeTap: (Challenge) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Challenges")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(activeChallenges, id: \.id) { challenge in
                    ActiveChallengeItem(challenge: challenge) {
                        onChallengeTap(challenge)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Active Challenge Item
struct ActiveChallengeItem: View {
    let challenge: Challenge
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Challenge icon
                Image(systemName: challenge.icon)
                    .font(.title2)
                    .foregroundColor(challenge.color)
                    .frame(width: 40, height: 40)
                    .background(challenge.color.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(challenge.currentProgress)/\(challenge.goal) \(challenge.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(challenge.color)
                                .frame(width: geometry.size.width * challenge.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(challenge.daysLeft)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(challenge.color)
                    
                    Text("days left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Available Challenges Card
struct AvailableChallengesCard: View {
    let onChallengeTap: (Challenge) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Join New Challenges")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(availableChallenges, id: \.id) { challenge in
                        AvailableChallengeCard(challenge: challenge) {
                            onChallengeTap(challenge)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Available Challenge Card
struct AvailableChallengeCard: View {
    let challenge: Challenge
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: challenge.icon)
                        .font(.title3)
                        .foregroundColor(challenge.color)
                    
                    Spacer()
                    
                    Text("\(challenge.participants)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Join button
                HStack {
                    Text("Join")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(challenge.color)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(challenge.duration) days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 160, height: 140)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Challenge Card
struct CreateChallengeCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            
            Text("Create Your Own Challenge")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Start a custom challenge and invite your friends to join")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Challenge") {
                // Handle challenge creation
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Friends Content
struct FriendsContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // Friend Requests
            FriendRequestsCard()
            
            // Leaderboard
            LeaderboardCard()
            
            // Find Friends
            FindFriendsCard()
        }
    }
}

// MARK: - Friend Requests Card
struct FriendRequestsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Friend Requests")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(friendRequests, id: \.id) { request in
                    FriendRequestItem(request: request)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Friend Request Item
struct FriendRequestItem: View {
    let request: FriendRequest
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(request.user.color.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(request.user.initials)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(request.user.color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(request.user.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Wants to be friends")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button("Accept") {
                    // Handle accept
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .cornerRadius(8)
                
                Button("Decline") {
                    // Handle decline
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Leaderboard Card
struct LeaderboardCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week's Leaderboard")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(Array(leaderboardUsers.enumerated()), id: \.offset) { index, user in
                    LeaderboardItem(user: user, rank: index + 1)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Leaderboard Item
struct LeaderboardItem: View {
    let user: LeaderboardUser
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(rankColor)
                .frame(width: 20)
            
            // User
            Circle()
                .fill(user.color.opacity(0.3))
                .frame(width: 35, height: 35)
                .overlay(
                    Text(user.initials)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(user.color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(user.points) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Badge
            if rank <= 3 {
                Image(systemName: rankIcon)
                    .font(.title3)
                    .foregroundColor(rankColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(rank <= 3 ? rankColor.opacity(0.05) : Color.clear)
        .cornerRadius(10)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primary
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal"
        default: return ""
        }
    }
}

// MARK: - Find Friends Card
struct FindFriendsCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.fill")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            
            Text("Find Friends")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Connect with friends to share your food journey together")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Invite Contacts") {
                    // Handle invite
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
                
                Button("Search Users") {
                    // Handle search
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Playlists Content
struct PlaylistsContent: View {
    var body: some View {
        VStack(spacing: 20) {
            // Your Playlists
            YourPlaylistsCard()
            
            // Shared with You
            SharedPlaylistsCard()
            
            // Trending Playlists
            TrendingPlaylistsCard()
        }
    }
}

// MARK: - Your Playlists Card
struct YourPlaylistsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Meal Playlists")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Create New") {
                    // Handle create playlist
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 12) {
                ForEach(userPlaylists, id: \.id) { playlist in
                    PlaylistItem(playlist: playlist)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Playlist Item
struct PlaylistItem: View {
    let playlist: MealPlaylist
    
    var body: some View {
        HStack(spacing: 12) {
            // Playlist cover
            RoundedRectangle(cornerRadius: 8)
                .fill(playlist.color.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: playlist.icon)
                        .font(.title3)
                        .foregroundColor(playlist.color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(playlist.mealCount) meals • \(playlist.likes) likes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Shared Playlists Card
struct SharedPlaylistsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shared with You")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(sharedPlaylists, id: \.id) { playlist in
                    SharedPlaylistItem(playlist: playlist)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Shared Playlist Item
struct SharedPlaylistItem: View {
    let playlist: SharedPlaylist
    
    var body: some View {
        HStack(spacing: 12) {
            // Creator avatar
            Circle()
                .fill(playlist.creator.color.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(playlist.creator.initials)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(playlist.creator.color)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("by \(playlist.creator.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(playlist.mealCount) meals")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button("Save") {
                    // Handle save
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.accentColor)
                .cornerRadius(6)
                
                Button("View") {
                    // Handle view
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
    }
}

// MARK: - Trending Playlists Card
struct TrendingPlaylistsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trending This Week")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(trendingPlaylists, id: \.id) { playlist in
                        TrendingPlaylistCard(playlist: playlist)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Trending Playlist Card
struct TrendingPlaylistCard: View {
    let playlist: TrendingPlaylist
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover
            RoundedRectangle(cornerRadius: 12)
                .fill(playlist.color.opacity(0.3))
                .frame(width: 120, height: 80)
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: playlist.icon)
                            .font(.title2)
                            .foregroundColor(playlist.color)
                        
                        Text("#\(playlist.rank)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(playlist.color)
                    }
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("\(playlist.saves) saves")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 120)
    }
}

// MARK: - Create Post View
struct CreatePostView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var caption = ""
    @State private var selectedMealType: MealType = .breakfast
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Photo placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            Text("Add Photo")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Button("Choose from Library") {
                                // Handle photo selection
                            }
                            .font(.subheadline)
                            .foregroundColor(.accentColor)
                        }
                    )
                
                // Caption
                VStack(alignment: .leading, spacing: 8) {
                    Text("Caption")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("What's cooking?", text: $caption, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                // Meal type
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meal Type")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            Button(action: { selectedMealType = mealType }) {
                                Text(mealType.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedMealType == mealType ? .white : mealType.color)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedMealType == mealType ? mealType.color : mealType.color.opacity(0.1))
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Share Meal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Share") {
                    // Handle share
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.semibold)
            )
        }
    }
}

// MARK: - Challenge Detail View
struct ChallengeDetailView: View {
    let challenge: Challenge
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: challenge.icon)
                            .font(.largeTitle)
                            .foregroundColor(challenge.color)
                            .frame(width: 80, height: 80)
                            .background(challenge.color.opacity(0.1))
                            .cornerRadius(20)
                        
                        Text(challenge.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(challenge.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Progress")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(challenge.currentProgress)/\(challenge.goal) \(challenge.unit)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text("\(Int(challenge.progress * 100))%")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(challenge.color)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(challenge.color)
                                        .frame(width: geometry.size.width * challenge.progress, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    
                    // Participants
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Participants (\(challenge.participants))")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Participant list would go here
                        Text("See who else is taking this challenge")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .contentShape(Rectangle())
            .navigationTitle("Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Data Models
enum SocialTab: CaseIterable {
    case feed, challenges, friends, playlists
    
    var displayName: String {
        switch self {
        case .feed: return "Feed"
        case .challenges: return "Challenges"
        case .friends: return "Friends"
        case .playlists: return "Playlists"
        }
    }
    
    var icon: String {
        switch self {
        case .feed: return "house.fill"
        case .challenges: return "trophy.fill"
        case .friends: return "person.2.fill"
        case .playlists: return "music.note.list"
        }
    }
}

struct User: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.compactMap { $0.first }.map { String($0) }.joined()
    }
}

struct Story: Identifiable {
    let id = UUID()
    let user: User
    let hasViewed: Bool
    let color: Color
}

struct FeedPost: Identifiable {
    let id = UUID()
    let user: User
    let caption: String
    let mealName: String
    let mealType: MealType
    let cookTime: Int
    let calories: Int
    let rating: Double
    let likes: Int
    let comments: Int
    let timeAgo: String
}

struct Challenge: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    let goal: Int
    let currentProgress: Int
    let unit: String
    let duration: Int
    let daysLeft: Int
    let participants: Int
    
    var progress: Double {
        Double(currentProgress) / Double(goal)
    }
}

struct FriendRequest: Identifiable {
    let id = UUID()
    let user: User
}

struct LeaderboardUser: Identifiable {
    let id = UUID()
    let name: String
    let points: Int
    let color: Color
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        return components.compactMap { $0.first }.map { String($0) }.joined()
    }
}

struct MealPlaylist: Identifiable {
    let id = UUID()
    let name: String
    let mealCount: Int
    let likes: Int
    let icon: String
    let color: Color
}

struct SharedPlaylist: Identifiable {
    let id = UUID()
    let name: String
    let creator: User
    let mealCount: Int
}

struct TrendingPlaylist: Identifiable {
    let id = UUID()
    let name: String
    let rank: Int
    let saves: Int
    let icon: String
    let color: Color
}

// MARK: - Sample Data
let sampleStories: [Story] = [
    Story(user: User(name: "Sarah Chen", color: .blue), hasViewed: false, color: .blue),
    Story(user: User(name: "Mike Johnson", color: .green), hasViewed: true, color: .green),
    Story(user: User(name: "Emma Davis", color: .purple), hasViewed: false, color: .purple),
    Story(user: User(name: "Alex Kim", color: .orange), hasViewed: false, color: .orange)
]

let samplePosts: [FeedPost] = [
    FeedPost(
        user: User(name: "Sarah Chen", color: .blue),
        caption: "Perfect post-workout meal! 💪 This Mediterranean bowl is packed with protein and flavor.",
        mealName: "Mediterranean Quinoa Bowl",
        mealType: .lunch,
        cookTime: 25,
        calories: 520,
        rating: 4.8,
        likes: 24,
        comments: 8,
        timeAgo: "2h ago"
    ),
    FeedPost(
        user: User(name: "Mike Johnson", color: .green),
        caption: "Sunday meal prep done! These overnight oats will fuel my week 🔥",
        mealName: "Berry Overnight Oats",
        mealType: .breakfast,
        cookTime: 5,
        calories: 320,
        rating: 4.6,
        likes: 18,
        comments: 5,
        timeAgo: "4h ago"
    )
]

let activeChallenges: [Challenge] = [
    Challenge(
        name: "7-Day Veggie Challenge",
        description: "Eat 5 servings of vegetables daily",
        icon: "leaf.fill",
        color: .green,
        goal: 35,
        currentProgress: 28,
        unit: "servings",
        duration: 7,
        daysLeft: 2,
        participants: 156
    ),
    Challenge(
        name: "Hydration Hero",
        description: "Drink 8 glasses of water daily",
        icon: "drop.fill",
        color: .blue,
        goal: 56,
        currentProgress: 42,
        unit: "glasses",
        duration: 7,
        daysLeft: 3,
        participants: 89
    )
]

let availableChallenges: [Challenge] = [
    Challenge(
        name: "Mediterranean Month",
        description: "Explore Mediterranean cuisine for 30 days",
        icon: "sun.max.fill",
        color: .orange,
        goal: 30,
        currentProgress: 0,
        unit: "meals",
        duration: 30,
        daysLeft: 30,
        participants: 234
    ),
    Challenge(
        name: "No Sugar Week",
        description: "Avoid added sugars for 7 days",
        icon: "xmark.circle.fill",
        color: .red,
        goal: 7,
        currentProgress: 0,
        unit: "days",
        duration: 7,
        daysLeft: 7,
        participants: 67
    )
]

let friendRequests: [FriendRequest] = [
    FriendRequest(user: User(name: "Jessica Wong", color: .pink)),
    FriendRequest(user: User(name: "David Miller", color: .indigo))
]

let leaderboardUsers: [LeaderboardUser] = [
    LeaderboardUser(name: "Sarah Chen", points: 1250, color: .blue),
    LeaderboardUser(name: "Mike Johnson", points: 1180, color: .green),
    LeaderboardUser(name: "Emma Davis", points: 1120, color: .purple),
    LeaderboardUser(name: "Alex Kim", points: 1050, color: .orange),
    LeaderboardUser(name: "You", points: 980, color: .accentColor)
]

let userPlaylists: [MealPlaylist] = [
    MealPlaylist(name: "Quick Weekday Meals", mealCount: 12, likes: 45, icon: "clock.fill", color: .blue),
    MealPlaylist(name: "Comfort Food Favorites", mealCount: 8, likes: 32, icon: "heart.fill", color: .red),
    MealPlaylist(name: "Healthy Breakfast Ideas", mealCount: 15, likes: 67, icon: "sun.rise.fill", color: .orange)
]

let sharedPlaylists: [SharedPlaylist] = [
    SharedPlaylist(name: "Sarah's Mediterranean Mix", creator: User(name: "Sarah Chen", color: .blue), mealCount: 20),
    SharedPlaylist(name: "Mike's Muscle Building Meals", creator: User(name: "Mike Johnson", color: .green), mealCount: 18)
]

let trendingPlaylists: [TrendingPlaylist] = [
    TrendingPlaylist(name: "Viral TikTok Recipes", rank: 1, saves: 1250, icon: "flame.fill", color: .red),
    TrendingPlaylist(name: "15-Minute Meals", rank: 2, saves: 980, icon: "clock.fill", color: .blue),
    TrendingPlaylist(name: "Plant-Based Power", rank: 3, saves: 756, icon: "leaf.fill", color: .green)
]