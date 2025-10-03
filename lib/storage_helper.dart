import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageHelper {
  static const String _usersKey = 'users';
  static const String _postsKey = 'posts';

  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = users.map((user) => {
      'id': user.id,
      'name': user.name,
      'bio': user.bio,
      'avatar': user.avatar,
      'location': user.location,
      'followers': user.followers,
      'following': user.following,
      'isVerified': user.isVerified,
      'isFollowing': user.isFollowing,
      'joinDate': user.joinDate.toIso8601String(),
    }).toList();
    await prefs.setString(_usersKey, jsonEncode(usersJson));
  }

  static Future<List<User>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey);
    if (usersString == null) return [];
    
    final usersJson = jsonDecode(usersString) as List;
    return usersJson.map((json) => User(
      id: json['id'],
      name: json['name'],
      bio: json['bio'],
      avatar: json['avatar'],
      location: json['location'],
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
      isVerified: json['isVerified'],
      isFollowing: json['isFollowing'],
      joinDate: DateTime.parse(json['joinDate']),
    )).toList();
  }

  static Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = posts.map((post) => {
      'id': post.id,
      'userId': post.userId,
      'content': post.content,
      'authorId': post.author.id,
      'authorName': post.author.name,
      'authorVerified': post.author.isVerified,
      'authorLocation': post.author.location,
      'imageUrl': post.imageUrl,
      'location': post.location,
      'likes': post.likes,
      'tags': post.tags,
      'createdAt': post.createdAt.toIso8601String(),
      'hasImage': post.hasImage,
      'isLiked': post.isLiked,
    }).toList();
    await prefs.setString(_postsKey, jsonEncode(postsJson));
  }

  static Future<List<Post>> loadPosts(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final postsString = prefs.getString(_postsKey);
    if (postsString == null) return [];
    
    final postsJson = jsonDecode(postsString) as List;
    return postsJson.map((json) {
      final author = users.firstWhere((u) => u.id == json['authorId']);
      return Post(
        id: json['id'],
        userId: json['userId'],
        content: json['content'],
        author: author,
        imageUrl: json['imageUrl'],
        location: json['location'],
        likes: List<String>.from(json['likes']),
        tags: List<String>.from(json['tags']),
        createdAt: DateTime.parse(json['createdAt']),
        hasImage: json['hasImage'],
        isLiked: json['isLiked'],
        comments: [],
      );
    }).toList();
  }
}