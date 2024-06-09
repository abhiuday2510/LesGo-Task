class Post {
  String id;
  String content;
  String? imageUrl;
  int likes;
  List<String> comments;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    List<String>? comments,
  }) : comments = comments ?? [];

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      content: json['content'],
      imageUrl: json['imageUrl'],
      likes: json['likes'],
      comments: List<String>.from(json['comments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
    };
  }
}
