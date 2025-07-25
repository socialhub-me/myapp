class ContentNotification {
  final String creatorName;
  final String title;
  final String timeAgo;
  final String sourcePlatform;
  final String thumbnailUrl;
  final String deepLinkUrl;
  bool isSaved;
  // Add creator profile picture URL if available

  ContentNotification({
    required this.creatorName,
    required this.title,
    required this.timeAgo,
    required this.sourcePlatform,
    required this.thumbnailUrl,
    required this.deepLinkUrl,
    this.isSaved = false,
  });

  // Factory method to create a ContentNotification from a map (for reading from Firestore)
  factory ContentNotification.fromMap(Map<String, dynamic> map) {
    return ContentNotification(
      creatorName: map['creatorName'] ?? '',
      title: map['title'] ?? '',
      timeAgo: map['timeAgo'] ?? '',
      sourcePlatform: map['sourcePlatform'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      deepLinkUrl: map['deepLinkUrl'] ?? '',
      isSaved: map['isSaved'] ?? false, // Read isSaved field
    );
  }

   // Method to convert ContentNotification to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'creatorName': creatorName,
      'title': title,
      'timeAgo': timeAgo,
      'sourcePlatform': sourcePlatform,
      'thumbnailUrl': thumbnailUrl,
      'deepLinkUrl': deepLinkUrl,
      'isSaved': isSaved,
    };
  }
}
