class UserData {
  final String uid;
  final String email;
  final List<String> linkedAccounts; // Add field for linked accounts

  UserData({required this.uid, required this.email, this.linkedAccounts = const []});

  // Factory method to create a UserData from a Firestore document
  factory UserData.fromFirestore(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      linkedAccounts: List<String>.from(data['linkedAccounts'] ?? []), // Read linked accounts
    );
  }

  // Method to convert UserData to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'linkedAccounts': linkedAccounts, // Include linked accounts
    };
  }
}
