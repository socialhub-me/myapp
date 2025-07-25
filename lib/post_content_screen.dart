import 'package:flutter/material.dart';

class PostContentScreen extends StatelessWidget {
  const PostContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Content')),
      body: const Center(child: Text('Post Content Screen')),
    );
  }
}
