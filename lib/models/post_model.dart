class Post {
  String id;
  String content;
  String? imageUrl;
  int likes;
  List<String> comments;
  String userId;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    List<String>? comments,
    required this.userId,
  }) : comments = comments ?? [];

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      content: json['content'],
      imageUrl: json['imageUrl'],
      likes: json['likes'],
      comments: List<String>.from(json['comments']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'userId': userId,
    };
  }
}
