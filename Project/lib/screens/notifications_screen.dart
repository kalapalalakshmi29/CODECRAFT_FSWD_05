import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class NotificationsScreen extends StatelessWidget {
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  '🔔 Notifications',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, appState, _) {
                    return ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: appState.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = appState.notifications[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFFFFF8F5)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF6B6B).withOpacity(0.1),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Icon(
                                  notification['type'] == 'like' 
                                      ? Icons.favorite_rounded
                                      : notification['type'] == 'follow'
                                          ? Icons.person_add_rounded
                                          : Icons.chat_bubble_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getNotificationText(notification),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _getTimeAgo(notification['createdAt']),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNotificationText(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'like':
        return 'Someone liked your post';
      case 'follow':
        return 'Someone started following you';
      case 'comment':
        return 'Someone commented on your post';
      default:
        return 'New notification';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}