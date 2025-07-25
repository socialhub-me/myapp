// Step 2: Account Selection Screen
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore
import 'content_aggregation_screen.dart'; // Import content aggregation screen

class AccountSelectionScreen extends StatefulWidget {
  // Change to StatefulWidget
  const AccountSelectionScreen({super.key});

  @override
  _AccountSelectionScreenState createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simple list to keep track of selected accounts (using strings for now)
  final List<String> _selectedAccounts = [];

  void _toggleAccountSelection(String account) {
    setState(() {
      if (_selectedAccounts.contains(account)) {
        _selectedAccounts.remove(account);
      } else {
        _selectedAccounts.add(account);
      }
    });
  }

  Future<void> _saveLinkedAccounts() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'linkedAccounts': _selectedAccounts,
        });
        print('Linked accounts saved for ${user.email}');
        // Navigate to the next screen after saving
        Navigator.pushReplacementNamed(
          // Use pushReplacementNamed
          context,
          '/contentAggregation', // Use named route
          arguments: _selectedAccounts, // Pass selected accounts as arguments
        );
      } catch (e) {
        print('Error saving linked accounts: $e');
      }
    }
  }

  // Helper to determine if an account is selected
  bool _isAccountSelected(String account) {
    return _selectedAccounts.contains(account);
  }

  // Helper to get the icon color based on selection
  Color _getIconColor(String account) {
    return _isAccountSelected(account) ? Colors.blue : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Accounts")),
      body: Center(
        // Center the column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Select at least two accounts to continue."),
            SizedBox(height: 20),
            // Example icons for linking accounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.facebook,
                    color: _getIconColor('facebook'),
                  ), // Color changes based on selection
                  onPressed: () =>
                      _toggleAccountSelection('facebook'), // Toggle selection
                ),
                IconButton(
                  icon: Icon(
                    Icons.camera_alt,
                    color: _getIconColor('instagram'),
                  ), // Color changes based on selection
                  onPressed: () =>
                      _toggleAccountSelection('instagram'), // Toggle selection
                ),
                IconButton(
                  icon: Icon(
                    Icons.video_library,
                    color: _getIconColor('youtube'),
                  ), // Color changes based on selection
                  onPressed: () =>
                      _toggleAccountSelection('youtube'), // Toggle selection
                ),
                // Add more icons as needed
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedAccounts.length >= 2
                  ? _saveLinkedAccounts
                  : null, // Enable button only if at least 2 accounts are selected
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
