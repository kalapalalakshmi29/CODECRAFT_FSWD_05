class User {
  final String id, name, bio, avatar, location;
  final List<String> followers, following;
  final bool isVerified, isFollowing;
  final DateTime joinDate;
  
  User({
    required this.id,
    required this.name,
    required this.bio,
    required this.avatar,
    required this.location,
    this.followers = const [],
    this.following = const [],
    this.isVerified = false,
    this.isFollowing = false,
    required this.joinDate,
  });
}

class Post {
  final String id, userId, content;
  final String? imageUrl, location;
  final List<String> likes, tags;
  final List<Comment> comments;
  final DateTime createdAt, timestamp;
  final bool isPinned, hasImage, isLiked;
  final User author;
  
  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.author,
    this.imageUrl,
    this.location,
    this.likes = const [],
    this.tags = const [],
    this.comments = const [],
    required this.createdAt,
    DateTime? timestamp,
    this.isPinned = false,
    this.hasImage = false,
    this.isLiked = false,
  }) : timestamp = timestamp ?? createdAt;
}

class Comment {
  final String id, userId, content;
  final DateTime createdAt;
  final List<String> likes;
  final User author;
  
  Comment({
    required this.id,
    required this.userId,
    required this.content,
    required this.author,
    required this.createdAt,
    this.likes = const [],
  });
}

class Story {
  final String id, userId, imageUrl;
  final DateTime createdAt;
  final bool isViewed;
  
  Story({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    this.isViewed = false,
  });
}