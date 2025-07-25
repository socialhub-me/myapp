import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'models/content_notification.dart'; // Import the ContentNotification model
import 'models/user_data.dart'; // Import UserData model
import 'dart:developer'; // Import for logging

class ContentAggregationScreen extends StatefulWidget {
  final List<String>? selectedAccounts;

  const ContentAggregationScreen({super.key, this.selectedAccounts});

  @override
  State<ContentAggregationScreen> createState() =>
      _ContentAggregationScreenState();
}

class _ContentAggregationScreenState extends State<ContentAggregationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0; // To track the selected tab in BottomNavigationBar
  List<ContentNotification> _savedNotifications =
      []; // List to hold saved notifications

  Future<void> _launchDeepLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      log('Could not launch $url');
      // Optionally show a user-friendly message
    }
  }

  Future<void> _saveNotification(ContentNotification notification) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final notificationMap = notification.toMap();

        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (userDoc.exists) {
          UserData userData = UserData.fromFirestore(userDoc.data()!);
          List<Map<String, dynamic>> currentSavedContent =
              List<Map<String, dynamic>>.from(userData.savedContent);

          bool alreadySaved = currentSavedContent.any(
            (saved) => saved['deepLinkUrl'] == notification.deepLinkUrl,
          );

          if (!alreadySaved) {
            currentSavedContent.add(notificationMap);
            await userDocRef.update({'savedContent': currentSavedContent});
            log('Notification saved to Firestore');
            if (_selectedIndex == 1) {
              _fetchSavedNotifications();
            }
          } else {
            log('Notification already saved');
          }
        } else {
          log('User document not found');
        }
      } catch (e) {
        log('Error saving notification: $e');
      }
    }
  }

  Future<void> _fetchSavedNotifications() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          UserData userData = UserData.fromFirestore(userDoc.data()!);
          setState(() {
            _savedNotifications = userData.savedContent
                .map((data) => ContentNotification.fromMap(data))
                .toList();
          });
        } else {
          setState(() {
            _savedNotifications = [];
          });
        }
      } catch (e) {
        log('Error fetching saved notifications: $e');
        setState(() {
          _savedNotifications = [];
        });
      }
    }
  }

  // Helper to determine if an account is selected (used for icon color)
  bool _isAccountSelected(String platformName, List<String> selectedAccounts) {
    return selectedAccounts.contains(platformName);
  }

  // Helper to get the platform icon
  Icon _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'apple':
        return const Icon(Icons.apple); // Placeholder icon for Apple
      case 'youtube':
        return const Icon(Icons.video_library); // YouTube icon
      case 'facebook':
        return const Icon(Icons.facebook); // Facebook icon
      case 'tiktok':
        return const Icon(Icons.music_note); // TikTok icon (using placeholder)
      case 'instagram':
        return const Icon(
          Icons.camera_alt,
        ); // Instagram icon (using placeholder)
      case 'pinterest':
        return const Icon(Icons.push_pin); // Use push_pin for Pinterest
      default:
        return const Icon(Icons.link); // Default icon
    }
  }

  // Helper widget to build platform icons with selection indication
  Widget _buildPlatformIcon(String platformName, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust spacing
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 2.0)
                  : null, // Placeholder selected color
            ),
            child: CircleAvatar(
              radius: 20, // Adjust size as needed
              backgroundColor: Colors.grey[800], // Placeholder background color
              child: _getPlatformIcon(
                platformName,
              ), // Use the helper to get the icon
              // TODO: Replace with actual platform logos/icons and potentially colorful rings
            ),
          ),
          const SizedBox(height: 4), // Add spacing for the label
          Text(platformName), // Display platform name as label
        ],
      ),
    );
  }

  // Simulate some placeholder notification data
  final List<ContentNotification> _notifications = [
    ContentNotification(
      creatorName: 'Creator 1',
      title: 'New Video Dropped!',
      timeAgo: '2 hours ago',
      sourcePlatform: 'YouTube',
      thumbnailUrl: '', // Placeholder for thumbnail URL
      deepLinkUrl:
          'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder YouTube link
    ),
    ContentNotification(
      creatorName: 'Creator 2',
      title: 'Check out my latest post',
      timeAgo: '1 day ago',
      sourcePlatform: 'Instagram',
      thumbnailUrl: '', // Placeholder for thumbnail URL
      deepLinkUrl: 'https://www.instagram.com/', // Placeholder Instagram link
    ),
    ContentNotification(
      creatorName: 'Creator 3',
      title: 'Fresh content on my page',
      timeAgo: '3 days ago',
      sourcePlatform: 'Facebook',
      thumbnailUrl: '', // Placeholder for thumbnail URL
      deepLinkUrl: 'https://www.facebook.com/', // Placeholder Facebook link
    ),
    ContentNotification(
      creatorName: 'Creator 4',
      title: 'New Pin Alert!',
      timeAgo: '1 hour ago',
      sourcePlatform: 'Pinterest',
      thumbnailUrl: '', // Placeholder for thumbnail URL
      deepLinkUrl: 'https://www.pinterest.com/', // Placeholder Pinterest link
    ),
    ContentNotification(
      creatorName: 'Creator 5',
      title: 'TikTok video is live',
      timeAgo: '5 hours ago',
      sourcePlatform: 'TikTok',
      thumbnailUrl: '', // Placeholder for thumbnail URL
      deepLinkUrl: 'https://www.tiktok.com/', // Placeholder TikTok link
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (_selectedIndex == 1) {
      _fetchSavedNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> accounts =
        (ModalRoute.of(context)?.settings.arguments as List<String>?) ??
        widget.selectedAccounts ??
        [];

    final List<ContentNotification> displayedNotifications = _selectedIndex == 1
        ? _savedNotifications
        : _notifications;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.alternate_email), // Placeholder icon
            const SizedBox(width: 8),
            const Expanded(child: Text("Masses Social")), // App Title
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedIndex == 1 ? '' : 'Tracking content from:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          if (_selectedIndex != 1)
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final platform = accounts[index];
                  return _buildPlatformIcon(
                    platform,
                    _isAccountSelected(platform, accounts),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedIndex == 1 ? 'Saved Content' : 'Your Favorites',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_selectedIndex != 1)
                  TextButton(onPressed: () {}, child: const Text('List View')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedNotifications.length,
              itemBuilder: (context, index) {
                final notification = displayedNotifications[index];
                final bool isSaved = _savedNotifications.any(
                  (saved) => saved.deepLinkUrl == notification.deepLinkUrl,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text(notification.creatorName[0]),
                    ),
                    title: Text(notification.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${notification.timeAgo} - ${notification.sourcePlatform}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        // You might add a small icon for the source platform here as well
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            if (isSaved) {
                              _removeSavedNotification(notification);
                            } else {
                              _saveNotification(notification);
                            }
                          },
                        ),
                        Container(
                          width: 80,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.play_arrow),
                          ), // Placeholder thumbnail area
                          // TODO: Display actual thumbnail using notification.thumbnailUrl
                        ),
                      ],
                    ),
                    onTap: () {
                      _launchDeepLink(notification.deepLinkUrl);
                    },
                  ),
                );
              },
            ),
          ),
          BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.edit),
                label: 'Edit Favorites',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bookmark),
                label: 'Saved Content',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.share),
                label: 'Share Content',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.post_add),
                label: 'Post Content',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 1) {
                _fetchSavedNotifications();
              } else if (index == 3) {
                Navigator.pushNamed(context, '/postContent');
              }
              // TODO: Implement logic for other tabs (Edit Favorites, Share Content)
            },
          ),
        ],
      ),
    );
  }

  Future<void> _removeSavedNotification(
    ContentNotification notification,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (userDoc.exists) {
          UserData userData = UserData.fromFirestore(userDoc.data()!);
          List<Map<String, dynamic>> currentSavedContent =
              List<Map<String, dynamic>>.from(userData.savedContent);

          currentSavedContent.removeWhere(
            (saved) => saved['deepLinkUrl'] == notification.deepLinkUrl,
          );

          await userDocRef.update({'savedContent': currentSavedContent});
          log('Notification removed from saved list');
          if (_selectedIndex == 1) {
            _fetchSavedNotifications();
          }
        } else {
          log('User document not found');
        }
      } catch (e) {
        log('Error removing saved notification: $e');
      }
    }
  }
}
