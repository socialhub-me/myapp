// Step 3: Content Aggregation
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'post_content_screen.dart'; // Import the post content screen
import 'masses_social_content_screen.dart'; // Import the masses social content screen
import 'models/content_notification.dart'; // Import the ContentNotification model
import 'models/user_data.dart'; // Import UserData model

class ContentAggregationScreen extends StatefulWidget { // Change to StatefulWidget
  // Receive selected accounts as an argument
  final List<String>? selectedAccounts;

  const ContentAggregationScreen({Key? key, this.selectedAccounts}) : super(key: key);

  @override
  _ContentAggregationScreenState createState() => _ContentAggregationScreenState();
}

class _ContentAggregationScreenState extends State<ContentAggregationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0; // To track the selected tab in BottomNavigationBar
  List<ContentNotification> _savedNotifications = []; // List to hold saved notifications

  // Function to launch a URL (deep link)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Handle the case where the URL cannot be launched
      print('Could not launch $url');
      // Optionally show a user-friendly message
    }
  }

  // Function to save a notification to Firestore
  Future<void> _saveNotification(ContentNotification notification) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Convert notification to a map to store in Firestore
        final notificationMap = {
          'creatorName': notification.creatorName,
          'title': notification.title,
          'timeAgo': notification.timeAgo,
          'sourcePlatform': notification.sourcePlatform,
          'thumbnailUrl': notification.thumbnailUrl,
          'deepLinkUrl': notification.deepLinkUrl,
        };

        // Get the current user document
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();

        if (userDoc.exists) {
          // Get the current saved content list
          UserData userData = UserData.fromFirestore(userDoc.data()!);
          List<Map<String, dynamic>> currentSavedContent = List<Map<String, dynamic>>.from(userData.savedContent);

          // Add the new notification map if it's not already saved (basic check)
          bool alreadySaved = currentSavedContent.any((saved) => saved['deepLinkUrl'] == notification.deepLinkUrl);

          if (!alreadySaved) {
            currentSavedContent.add(notificationMap);
            // Update the user document with the new saved content list
            await userDocRef.update({'savedContent': currentSavedContent});
            print('Notification saved to Firestore');
             // Refresh saved notifications list if on the Saved Content tab
             if (_selectedIndex == 1) {
                 _fetchSavedNotifications();
             }
          } else {
             print('Notification already saved');
          }

        } else {
          print('User document not found');
        }
      } catch (e) {
        print('Error saving notification: $e');
      }
    }
  }

   // Function to fetch saved notifications from Firestore
   Future<void> _fetchSavedNotifications() async {
      final user = _auth.currentUser;
      if (user != null) {
         try {
            final userDoc = await _firestore.collection('users').doc(user.uid).get();
            if (userDoc.exists) {
               UserData userData = UserData.fromFirestore(userDoc.data()!);
               setState(() {
                  _savedNotifications = userData.savedContent.map((data) => ContentNotification.fromMap(data)).toList();
               });
            } else {
               setState(() {
                 _savedNotifications = [];
               });
            }
         } catch (e) {
            print('Error fetching saved notifications: $e');
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

  // Helper widget to build platform icons with selection indication
  Widget _buildPlatformIcon(String platformName, IconData iconData, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust spacing
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.blue, width: 2.0) : null, // Placeholder selected color
        ),
        child: CircleAvatar(
          radius: 20, // Adjust size as needed
          backgroundColor: Colors.grey[800], // Placeholder background color
          child: Icon(iconData, color: isSelected ? Colors.blue : Colors.white, size: 25), // Placeholder icon color
           // TODO: Replace with actual platform logos/icons and potentially colorful rings
        ),
      ),
    );
  }

  // Simulate some placeholder notification data (moved inside State for potential future use)
  final List<ContentNotification> _notifications = [
      ContentNotification(
        creatorName: 'Creator 1',
        title: 'New Video Dropped!',
        timeAgo: '2 hours ago',
        sourcePlatform: 'YouTube',
        thumbnailUrl: '', // Placeholder for thumbnail URL
        deepLinkUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Placeholder YouTube link
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
    // Fetch saved notifications when the screen initializes if on the Saved Content tab
     if (_selectedIndex == 1) {
        _fetchSavedNotifications();
     }
  }


  @override
  Widget build(BuildContext context) {
    // Access the selected accounts passed as arguments
    final List<String> accounts = (ModalRoute.of(context)?.settings.arguments as List<String>?) ?? widget.selectedAccounts ?? [];

    // Determine which list to display
    final List<ContentNotification> displayedNotifications = _selectedIndex == 1 ? _savedNotifications : _notifications; // Show saved or all notifications

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // User Profile Icon
            CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person)),
            SizedBox(width: 8),
            // App Logo/Icon
            Icon(Icons.alternate_email), // Placeholder icon
            SizedBox(width: 8),
            Expanded(child: Text("Masses Social")), // App Title
          ],
        ),
        actions: [
          // Notification Icon
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide.none), // Rounded border
                filled: true, // Fill with color
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20), // Adjust padding
              ),
            ),
          ),
          // Social Media Icons Row (Horizontally Scrollable)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Align icons to the start
                children: [
                   SizedBox(width: 4), // Add some spacing at the beginning
                  // Display ALL supported platform icons, with visual indication for selected ones
                  _buildPlatformIcon('apple', Icons.apple, _isAccountSelected('apple', accounts)), // Apple
                  _buildPlatformIcon('youtube', Icons.video_library, _isAccountSelected('youtube', accounts)), // YouTube
                  _buildPlatformIcon('facebook', Icons.facebook, _isAccountSelected('facebook', accounts)), // Facebook
                  _buildPlatformIcon('tiktok', Icons.tiktok, _isAccountSelected('tiktok', accounts)), // TikTok (using placeholder icon)
                  _buildPlatformIcon('instagram', Icons.camera_alt, _isAccountSelected('instagram', accounts)), // Instagram (using placeholder icon)
                  _buildPlatformIcon('pinterest', Icons.pinterest, _isAccountSelected('pinterest', accounts)), // Pinterest (using placeholder icon)
                  // Add more icons for other supported platforms
                   SizedBox(width: 4), // Add some spacing at the end
                ],
              ),
            ),
          ),
          // Content List Section Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedIndex == 1 ? 'Saved Content' : 'Your Favorites', // Change title based on selected tab
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(onPressed: () {}, child: Text('List View')),
              ],
            ),
          ),
          // Content Notifications List
          Expanded(
            child: ListView.builder(
              itemCount: displayedNotifications.length, // Use the number of displayed notifications
              itemBuilder: (context, index) {
                final notification = displayedNotifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blueGrey, child: Text(notification.creatorName[0])),
                    title: Text(notification.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${notification.timeAgo} - ${notification.sourcePlatform}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        // You might add a small icon for the source platform here as well
                      ],
                    ),
                    trailing: Row( // Add Row for multiple trailing icons
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton( // Save/Unsave Icon
                           // TODO: Determine if the notification is already saved and show the appropriate icon/color
                           icon: Icon(Icons.bookmark_border), // Placeholder icon
                           onPressed: () {
                             _saveNotification(notification); // Call save function
                           },
                        ),
                         Container(
                           width: 80,
                           height: 60,
                           color: Colors.grey[300],
                            child: Center(child: Icon(Icons.play_arrow)), // Placeholder thumbnail area
                           // TODO: Display actual thumbnail using notification.thumbnailUrl
                         ),
                      ],
                    ),
                    onTap: () { // Implement tap to launch deep link
                      _launchUrl(notification.deepLinkUrl);
                    },
                  ),
                );
              },
            ),
          ),
          // Bottom Navigation Bar
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.edit), // Edit Favorites
                label: 'Edit Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark), // Saved Content
                label: 'Saved Content',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share), // Share Content
                label: 'Share Content',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add), // Post Content
                label: 'Post Content',
              ),
            ],
            currentIndex: _selectedIndex, // Set the current index
            selectedItemColor: Colors.blue, // Placeholder color
            unselectedItemColor: Colors.grey, // Placeholder color
            onTap: (index) { // Handle tap on BottomNavigationBar items
              setState(() {
                _selectedIndex = index;
              });
               // Navigate or perform action based on selected index
              if (index == 1) { // Saved Content tab
                _fetchSavedNotifications(); // Fetch saved notifications
              } else if (index == 3) { // Post Content tab
                 Navigator.pushNamed(context, '/postContent'); // Navigate to Post Content Screen
              }
               // TODO: Implement logic for other tabs (Edit Favorites, Share Content)
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to build platform icons with selection indication
  Widget _buildPlatformIcon(String platformName, IconData iconData, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust spacing
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.blue, width: 2.0) : null, // Placeholder selected color
        ),
        child: CircleAvatar(
          radius: 20, // Adjust size as needed
          backgroundColor: Colors.grey[800], // Placeholder background color
          child: Icon(iconData, color: isSelected ? Colors.blue : Colors.white, size: 25), // Placeholder icon color
           // TODO: Replace with actual platform logos/icons and potentially colorful rings
        ),
      ),
    );
  }

  // Helper method to create ContentNotification from a map (for reading from Firestore)
  // Add this factory method to your ContentNotification class definition as well
  // factory ContentNotification.fromMap(Map<String, dynamic> map) {
  //   return ContentNotification(
  //     creatorName: map['creatorName'] ?? '',
  //     title: map['title'] ?? '',
  //     timeAgo: map['timeAgo'] ?? '',
  //     sourcePlatform: map['sourcePlatform'] ?? '',
  //     thumbnailUrl: map['thumbnailUrl'] ?? '',
  //     deepLinkUrl: map['deepLinkUrl'] ?? '',
  //   );
  // }
}

// Add this factory method to your ContentNotification class definition in models/content_notification.dart
// factory ContentNotification.fromMap(Map<String, dynamic> map) {
//   return ContentNotification(
//     creatorName: map['creatorName'] ?? '',
//     title: map['title'] ?? '',
//     timeAgo: map['timeAgo'] ?? '',
//     sourcePlatform: map['sourcePlatform'] ?? '',
//     thumbnailUrl: map['thumbnailUrl'] ?? '',
//     deepLinkUrl: map['deepLinkUrl'] ?? '',
//   );
// }
