class FeedbackModel {
  final String userId;
  final int rating;
  final String feedback;
  final String photoUrl;
  final String username;
  final String feedbackReceiverId;
  String feedbackId;

  FeedbackModel({
    required this.userId,
    required this.rating,
    required this.feedback,
    required this.photoUrl,
    required this.username,
    required this.feedbackId,
    required this.feedbackReceiverId,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'rating': rating,
        'feedback': feedback,
        'photoUrl': photoUrl,
        'username': username,
        'feedbackId': feedbackId,
        'feedbackReceiverId': feedbackReceiverId,
      };
}
