import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../app_state.dart';
import '../models.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showFloatingElements = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController.forward();
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && _showFloatingElements) {
        setState(() => _showFloatingElements = false);
      } else if (_scrollController.offset <= 50 && !_showFloatingElements) {
        setState(() => _showFloatingElements = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8F5), Color(0xFFFFE8E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            return Stack(
              children: [
                _buildMainContent(appState),
                _buildFloatingElements(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(AppState appState) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 1000));
        _slideController.reset();
        _slideController.forward();
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          _buildDynamicAppBar(appState),
          _buildSearchBar(),
          _buildLiveStoriesSection(appState),
          _buildReelsSection(),
          _buildTrendingSection(),
          _buildPostsFeed(appState),
        ],
      ),
    );
  }

  Widget _buildDynamicAppBar(AppState appState) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF6B6B).withOpacity(0.1),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🧡 CoralConnect',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                        Text(
                          'Welcome back, ${appState.currentUserName.split(' ')[0]}! 🌟',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildGlowingIcon(Icons.notifications_rounded, () {}),
                      SizedBox(width: 12),
                      _buildProfileButton(appState),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF6B6B).withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search posts, people, hashtags...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Container(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.search_rounded, color: Color(0xFFFF6B6B)),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.clear_rounded, color: Colors.grey[500]),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFFFF0F0)],
              ),
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF6B6B).withOpacity(0.3 + (_pulseController.value * 0.2)),
                  blurRadius: 12 + (_pulseController.value * 6),
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: Color(0xFFFF6B6B)),
          );
        },
      ),
    );
  }

  Widget _buildProfileButton(AppState appState) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildLiveStoriesSection(AppState appState) {
    return SliverToBoxAdapter(
      child: Container(
        height: 110,
        margin: EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: appState.users.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildCreateStoryCard();
            return _buildStoryCard(appState.users[index - 1], index);
          },
        ),
      ),
    );
  }

  Widget _buildCreateStoryCard() {
    return GestureDetector(
      onTap: () => _showStoryDialog('Create Your Story'),
      child: Container(
        width: 75,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(37),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF6B6B).withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
            ),
            SizedBox(height: 8),
            Text(
              '🌟 Your Story',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(User user, int index) {
    return GestureDetector(
      onTap: () => _showStoryDialog('${user.name}\'s Story'),
      child: Container(
        width: 75,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    borderRadius: BorderRadius.circular(37),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: Icon(Icons.person_rounded, size: 32, color: Colors.grey[600]),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.circle, color: Colors.white, size: 8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              user.name.split(' ')[0],
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF6B6B).withOpacity(0.1),
              Color(0xFFFF8E53).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Color(0xFFFF6B6B).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF6B6B).withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.trending_up_rounded, color: Colors.white, size: 18),
                ),
                SizedBox(width: 12),
                Text(
                  '🔥 Trending Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTrendingTag('#Design', Color(0xFFFF6B6B)),
                  _buildTrendingTag('#Food', Color(0xFFFF8E53)),
                  _buildTrendingTag('#Fitness', Color(0xFFFF6B6B)),
                  _buildTrendingTag('#Art', Color(0xFFFF8E53)),
                  _buildTrendingTag('#Wellness', Color(0xFFFF6B6B)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTag(String tag, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPostsFeed(AppState appState) {
    final filteredPosts = _searchQuery.isEmpty 
        ? appState.posts 
        : appState.posts.where((post) => 
            post.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            post.author.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            post.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
          ).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _slideController.value)),
                child: Opacity(
                  opacity: _slideController.value,
                  child: _buildAdvancedPostCard(filteredPosts[index], appState),
                ),
              );
            },
          );
        },
        childCount: filteredPosts.length,
      ),
    );
  }

  Widget _buildAdvancedPostCard(Post post, AppState appState) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFFAFA)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0xFFFF6B6B).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF6B6B).withOpacity(0.1),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),
          _buildPostContent(post),
          _buildInteractiveActions(post, appState),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Post post) {
    return Padding(
      padding: EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.author.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (post.author.isVerified) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.verified_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${post.timestamp.hour}:${post.timestamp.minute.toString().padLeft(2, '0')} • ${post.author.location}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF8F5), Colors.white],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.more_horiz_rounded, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(Post post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
          ),
          if (post.tags.isNotEmpty) ...[
            SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: post.tags.map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B).withOpacity(0.15), Color(0xFFFF8E53).withOpacity(0.15)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )).toList(),
            ),
          ],
          if (post.hasImage) ...[
            SizedBox(height: 18),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF8F5), Color(0xFFFFF0F0)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFFF6B6B).withOpacity(0.1)),
              ),
              child: Icon(Icons.image_rounded, size: 70, color: Colors.grey[400]),
            ),
          ],
          SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildInteractiveActions(Post post, AppState appState) {
    return Container(
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFBFC), Colors.white],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          _buildActionButton(
            post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            '${post.likes.length}',
            post.isLiked ? Colors.red : Colors.grey[600]!,
            () => appState.toggleLike(post.id),
          ),
          SizedBox(width: 28),
          _buildActionButton(
            Icons.chat_bubble_rounded,
            '${post.comments.length}',
            Colors.grey[600]!,
            () => _showCommentsSheet(post, appState),
          ),
          SizedBox(width: 28),
          _buildActionButton(
            Icons.share_rounded,
            'Share',
            Colors.grey[600]!,
            () {},
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFFFF8F5)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.bookmark_border_rounded, color: Colors.grey[600], size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: _showFloatingElements ? 100 : -60,
      right: 20,
      child: Column(
        children: [
          _buildFloatingActionButton(Icons.video_call_rounded, () {}),
          SizedBox(height: 12),
          _buildFloatingActionButton(Icons.camera_alt_rounded, () {}),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFF6B6B).withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildReelsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.play_circle_rounded, color: Colors.white, size: 18),
                ),
                SizedBox(width: 12),
                Text(
                  '🎬 Reels for You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showReelDialog('Reel ${index + 1}'),
                    child: Container(
                      width: 120,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.play_circle_filled_rounded,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reel ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${Random().nextInt(100) + 10}K views',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Container(
          height: 300,
          width: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera_rounded, color: Colors.white, size: 60),
                SizedBox(height: 16),
                Text(
                  'Story Content',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to view full story',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  void _showReelDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Container(
          height: 400,
          width: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 80),
                SizedBox(height: 20),
                Text(
                  'Now Playing',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Reel is playing...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.favorite_rounded, color: Colors.red, size: 30),
                    Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 30),
                    Icon(Icons.share_rounded, color: Colors.white, size: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(Post post, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFFBFC)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 5,
              margin: EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              '💬 Comments (${post.comments.length})',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 22),
                itemCount: post.comments.length,
                itemBuilder: (context, index) {
                  final comment = post.comments[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            ),
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFF8F5), Color(0xFFFFFBFC)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.author.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}