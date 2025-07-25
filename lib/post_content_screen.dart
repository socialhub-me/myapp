// Step 4: Post Content Pageclass PostContentScreen extends StatelessWidget {  @override  Widget build(BuildContext context) {    return Scaffold(      appBar: AppBar(title: Text("Post Content")),      body: Column(        children: [          // Search Bar          TextField(            decoration: InputDecoration(              hintText: 'Search',            ),          ),          // Message Input          TextField(            decoration: InputDecoration(              hintText: 'Write a message to the Masses!',            ),          ),          // Social Media Platform Selection          Row(            mainAxisAlignment: MainAxisAlignment.spaceEvenly,            children: [              IconButton(icon: Icon(Icons.youtube_searched_for), onPressed: () {}),              IconButton(icon: Icon(Icons.facebook), onPressed: () {}),              IconButton(icon: Icon(Icons.camera_alt), onPressed: () {}),              IconButton(icon: Icon(Icons.video_library), onPressed: () {}),            ],          ),          // Send Button          ElevatedButton(            onPressed: () {              // Logic to send post            },            child: Text('Send Post'),          ),        ],      ),    );  }}import 'package:flutter/material.dart';

class PostContentScreen extends StatelessWidget {
  const PostContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Content')),
      body: const Center(child: Text('Post Content Screen')),
    );
  }
}
