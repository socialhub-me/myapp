class UserData {
  final String uid;
  final String email;
  final List<String> linkedAccounts;
  final List<Map<String, dynamic>> savedContent; // Add field for saved content

  UserData({required this.uid, required this.email, this.linkedAccounts = const [], this.savedContent = const []});

  // Factory method to create a UserData from a Firestore document
  factory UserData.fromFirestore(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      linkedAccounts: List<String>.from(data['linkedAccounts'] ?? []), // Read linked accounts
      savedContent: List<Map<String, dynamic>>.from(data['savedContent'] ?? []), // Read saved content
    );
  }

  // Method to convert UserData to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'linkedAccounts': linkedAccounts,
      'savedContent': savedContent, // Include saved content
    };
  }
}
