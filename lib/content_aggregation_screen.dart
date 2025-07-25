// Step 3: Content Aggregation
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'post_content_screen.dart'; // Import the post content screen
import 'masses_social_content_screen.dart'; // Import the masses social content screen
import 'models/content_notification.dart'; // Import the ContentNotification model

class ContentAggregationScreen extends StatelessWidget {
  // Receive selected accounts as an argument
  final List<String>? selectedAccounts;

  const ContentAggregationScreen({Key? key, this.selectedAccounts}) : super(key: key);

  // Function to launch a URL (deep link)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Handle the case where the URL cannot be launched
      print('Could not launch $url');
      // Optionally show a user-friendly message
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the selected accounts passed as arguments
    final List<String> accounts = (ModalRoute.of(context)?.settings.arguments as List<String>?) ?? selectedAccounts ?? [];

    // Simulate some placeholder notification data
    final List<ContentNotification> notifications = [
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
                  _buildPlatformIcon('apple', Icons.apple, accounts.contains('apple')), // Apple
                  _buildPlatformIcon('youtube', Icons.video_library, accounts.contains('youtube')), // YouTube
                  _buildPlatformIcon('facebook', Icons.facebook, accounts.contains('facebook')), // Facebook
                  _buildPlatformIcon('tiktok', Icons.tiktok, accounts.contains('tiktok')), // TikTok (using placeholder icon)
                  _buildPlatformIcon('instagram', Icons.camera_alt, accounts.contains('instagram')), // Instagram (using placeholder icon)
                  _buildPlatformIcon('pinterest', Icons.pinterest, accounts.contains('pinterest')), // Pinterest (using placeholder icon)
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
                Text('Your Favorites', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: () {}, child: Text('List View')),
              ],
            ),
          ),
          // Content Notifications List
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length, // Use the number of placeholder notifications
              itemBuilder: (context, index) {
                final notification = notifications[index];
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
                    trailing: Container(
                      width: 80,
                      height: 60,
                      color: Colors.grey[300],
                       child: Center(child: Icon(Icons.play_arrow)), // Placeholder thumbnail area
                      // TODO: Display actual thumbnail using notification.thumbnailUrl
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
            items: const <BottomNavigationBarBarItem>[
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
            currentIndex: 0, // Placeholder: set to the index of the active tab
            selectedItemColor: Colors.blue, // Placeholder color
            unselectedItemColor: Colors.grey, // Placeholder color
            onTap: (index) { // Placeholder onTap
              // Handle navigation to different sections
              if (index == 3) { // Index 3 corresponds to Post Content
                 Navigator.pushNamed(context, '/postContent'); // Navigate to Post Content Screen
              }
              // TODO: Implement navigation for other bottom navigation items
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
}
