enum VideoStatus { viewed, unviewed }

class VideoHistoryItem {
  final String id;
  final String title;
  final String? subtitle;
  final String duration;
  final int? daysAgo;
  final String? fileSize;
  final VideoStatus? status;
  final String thumbnailAsset;

  VideoHistoryItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.duration,
    this.daysAgo,
    this.fileSize,
    this.status,
    required this.thumbnailAsset,
  });

  VideoHistoryItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? duration,
    int? daysAgo,
    String? fileSize,
    VideoStatus? status,
    String? thumbnailAsset,
  }) {
    return VideoHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      duration: duration ?? this.duration,
      daysAgo: daysAgo ?? this.daysAgo,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      thumbnailAsset: thumbnailAsset ?? this.thumbnailAsset,
    );
  }
}