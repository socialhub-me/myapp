class ContentNotification {
  final String creatorName;
  final String title;
  final String timeAgo;
  final String sourcePlatform;
  final String thumbnailUrl;
  final String deepLinkUrl;
  // Add creator profile picture URL if available

  ContentNotification({
    required this.creatorName,
    required this.title,
    required this.timeAgo,
    required this.sourcePlatform,
    required this.thumbnailUrl,
    required this.deepLinkUrl,
  });
}
