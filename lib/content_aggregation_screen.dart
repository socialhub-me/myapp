// Step 3: Content Aggregation
import 'package:flutter/material.dart';
import 'post_content_screen.dart'; // Import the post content screen
import 'masses_social_content_screen.dart'; // Import the masses social content screen

class ContentAggregationScreen extends StatelessWidget {
  // Receive selected accounts as an argument
  final List<String>? selectedAccounts;

  const ContentAggregationScreen({Key? key, this.selectedAccounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the selected accounts passed as arguments
    final List<String> accounts = (ModalRoute.of(context)?.settings.arguments as List<String>?) ?? selectedAccounts ?? [];

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
          // Social Media Icons Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Conditionally display icons based on selected accounts
                if (accounts.contains('apple')) Icon(Icons.apple), // Placeholder icon for Apple
                if (accounts.contains('youtube')) Icon(Icons.video_library), // YouTube icon
                if (accounts.contains('facebook')) Icon(Icons.facebook), // Facebook icon
                if (accounts.contains('tiktok')) Icon(Icons.tiktok), // Placeholder icon for TikTok
                if (accounts.contains('instagram')) Icon(Icons.camera_alt), // Instagram icon
                if (accounts.contains('pinterest')) Icon(Icons.pinterest), // Placeholder icon for Pinterest
                // Add more icons as needed based on your supported platforms
              ],
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
          // Content List (Placeholder)
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder item count
              itemBuilder: (context, index) {
                // Placeholder Content Item
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Creator Profile Picture (Placeholder)
                        CircleAvatar(backgroundColor: Colors.blueGrey, child: Text('C$index')),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Creator Name $index', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Content Title $index'),
                              Text('Time Ago - Source', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        // Content Thumbnail (Placeholder)
                        Container(
                          width: 80,
                          height: 60,
                          color: Colors.grey[300],
                          child: Center(child: Icon(Icons.play_arrow)), // Placeholder thumbnail
                        ),
                      ],
                    ),
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
}
