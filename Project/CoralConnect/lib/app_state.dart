import 'package:flutter/material.dart';
import 'models.dart';
import 'storage_helper.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _initializePosts();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final users = await StorageHelper.loadUsers();
      final posts = await StorageHelper.loadPosts(_users);
      if (users.isNotEmpty) {
        _users.clear();
        _users.addAll(users);
      }
      if (posts.isNotEmpty) {
        _posts.clear();
        _posts.addAll(posts);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
    }
  }
  
  Future<void> _saveData() async {
    await StorageHelper.saveUsers(_users);
    await StorageHelper.savePosts(_posts);
  }
  final List<User> _users = [
    User(id: '1', name: 'Maya Chen', bio: 'Digital Artist & UI Designer 🎨', avatar: '', location: 'San Francisco, CA', followers: ['2', '3'], following: ['2'], isVerified: true, joinDate: DateTime(2022, 1, 15)),
    User(id: '2', name: 'Alex Rivera', bio: 'Food Blogger 🍕 | Recipe Creator 👨‍🍳', avatar: '', location: 'Austin, TX', followers: ['1', '3'], following: ['1', '3'], joinDate: DateTime(2021, 8, 20)),
    User(id: '3', name: 'Jordan Kim', bio: 'Fitness Coach 💪 | Wellness Advocate 🧘‍♀️', avatar: '', location: 'Los Angeles, CA', followers: ['1'], following: ['1', '2'], isVerified: true, joinDate: DateTime(2023, 3, 10)),
  ];

  late final List<Post> _posts;

  void _initializePosts() {
    _posts = [
      Post(
        id: '1', 
        userId: '1', 
        content: 'Just finished this amazing UI design project! The coral color palette turned out perfect 🎨✨', 
        author: _users[0],
        imageUrl: null, 
        location: 'Design Studio, SF', 
        tags: ['design', 'ui', 'coral', 'creative'], 
        likes: ['2', '3'], 
        createdAt: DateTime.now().subtract(Duration(hours: 2)), 
        hasImage: true,
        isLiked: true,
        comments: [
          Comment(id: '1', userId: '2', content: 'This looks incredible! Love the color choice! 😍', author: _users[1], createdAt: DateTime.now().subtract(Duration(hours: 1))),
        ]
      ),
      Post(
        id: '2', 
        userId: '2', 
        content: 'Made the most delicious coral-colored smoothie bowl today! Recipe in my bio 🥣🧡', 
        author: _users[1],
        imageUrl: null, 
        location: 'Home Kitchen, Austin', 
        tags: ['food', 'healthy', 'recipe', 'smoothie'], 
        likes: ['1'], 
        createdAt: DateTime.now().subtract(Duration(minutes: 30)), 
        hasImage: false,
        isLiked: false,
        comments: []
      ),
    ];
    _saveData();
  }

  final List<Story> _stories = [
    Story(id: '1', userId: '1', imageUrl: '', createdAt: DateTime.now().subtract(Duration(hours: 3))),
    Story(id: '2', userId: '2', imageUrl: '', createdAt: DateTime.now().subtract(Duration(hours: 1))),
  ];

  final List<Map<String, dynamic>> _notifications = [
    {'id': '1', 'type': 'like', 'userId': '2', 'postId': '1', 'createdAt': DateTime.now().subtract(Duration(minutes: 30))},
    {'id': '2', 'type': 'follow', 'userId': '3', 'createdAt': DateTime.now().subtract(Duration(hours: 1))},
    {'id': '3', 'type': 'comment', 'userId': '2', 'postId': '1', 'createdAt': DateTime.now().subtract(Duration(hours: 2))},
  ];

  String _currentUserId = '1';
  String _currentUserName = 'User';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoggedIn = false;
  Map<String, String> _credentials = {};

  List<User> get users => _users;
  List<Post> get posts => _posts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<Story> get stories => _stories;
  List<Map<String, dynamic>> get notifications => _notifications;
  String get currentUserId => _currentUserId;
  String get currentUserName => _currentUserName;
  User get currentUser {
    try {
      return _users.firstWhere((u) => u.id == _currentUserId);
    } catch (e) {
      return User(
        id: _currentUserId,
        name: _currentUserName,
        bio: 'New User',
        avatar: '',
        location: 'USA',
        joinDate: DateTime.now(),
      );
    }
  }
  ThemeMode get themeMode => _themeMode;
  bool get isLoggedIn => _isLoggedIn;

  User getUserById(String id) => _users.firstWhere((u) => u.id == id);

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void login(String email, String password) {
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateUserName(String name) {
    _currentUserName = name;
    notifyListeners();
  }

  void register(String email, String password, String name) {
    _credentials[email] = password;
    _currentUserName = name;
    _isLoggedIn = true;
    _saveData();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void addPost(String content, {String? imageUrl, String? location, List<String>? tags}) {
    final post = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId,
      content: content,
      author: currentUser,
      imageUrl: imageUrl,
      location: location,
      tags: tags ?? [],
      createdAt: DateTime.now(),
      hasImage: imageUrl != null,
      isLiked: false,
      likes: [],
      comments: [],
    );
    _posts.insert(0, post);
    _saveData();
    notifyListeners();
  }

  void toggleLike(String postId) {
    final post = _posts.firstWhere((p) => p.id == postId);
    if (post.likes.contains(_currentUserId)) {
      post.likes.remove(_currentUserId);
    } else {
      post.likes.add(_currentUserId);
      if (post.userId != _currentUserId) {
        _generateLikeNotification(post.userId, postId);
      }
    }
    notifyListeners();
  }

  void _generateLikeNotification(String postOwnerId, String postId) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'like',
      'userId': _currentUserId,
      'postId': postId,
      'createdAt': DateTime.now(),
    });
  }

  void addComment(String postId, String content) {
    final post = _posts.firstWhere((p) => p.id == postId);
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId,
      content: content,
      author: currentUser,
      createdAt: DateTime.now(),
    );
    post.comments.add(comment);
    
    if (post.userId != _currentUserId) {
      _generateCommentNotification(post.userId, postId, content);
    }
    
    notifyListeners();
  }

  void _generateCommentNotification(String postOwnerId, String postId, String content) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'comment',
      'userId': _currentUserId,
      'postId': postId,
      'content': content,
      'createdAt': DateTime.now(),
    });
  }

  void toggleFollow(String userId) {
    final user = _users.firstWhere((u) => u.id == userId);
    final currentUser = _users.firstWhere((u) => u.id == _currentUserId);
    
    if (currentUser.following.contains(userId)) {
      currentUser.following.remove(userId);
      user.followers.remove(_currentUserId);
    } else {
      currentUser.following.add(userId);
      user.followers.add(_currentUserId);
      _generateFollowNotification(userId);
    }
    notifyListeners();
  }

  void _generateFollowNotification(String userId) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'follow',
      'userId': _currentUserId,
      'createdAt': DateTime.now(),
    });
  }

  List<Map<String, dynamic>> getTrendingContent() {
    final trending = <Map<String, dynamic>>[];
    final popularPosts = _posts.where((p) => p.likes.length > 1).toList()
      ..sort((a, b) => b.likes.length.compareTo(a.likes.length));
    
    for (final post in popularPosts.take(10)) {
      trending.add({
        'type': 'post',
        'data': post,
        'engagement': post.likes.length + post.comments.length,
      });
    }
    
    return trending;
  }

  List<String> getTrendingHashtags() {
    final tagCounts = <String, int>{};
    
    for (final post in _posts) {
      for (final tag in post.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTags.take(10).map((e) => e.key).toList();
  }

  List<User> getSuggestedUsers() {
    return _users.where((u) => 
      u.id != _currentUserId && 
      !currentUser.following.contains(u.id)
    ).toList();
  }

  void addStory(String imageUrl) {
    final story = Story(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
    _stories.add(story);
    notifyListeners();
  }
}