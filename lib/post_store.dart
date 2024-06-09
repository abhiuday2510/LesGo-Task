import 'package:mobx/mobx.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post_model.dart';

part 'post_store.g.dart';

class PostStore = _PostStore with _$PostStore;

abstract class _PostStore with Store {
  static const apiUrl = 'http://192.168.1.11:3000/posts';

  @observable
  ObservableList<Post> posts = ObservableList<Post>();

  @action
  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> postList = json.decode(response.body);
        posts = ObservableList<Post>.of(
          postList.map((post) => Post.fromJson(post)).toList(),
        );
        print("Fetched posts: ${posts.length}");
      } else {
        print("Failed to fetch posts: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  @action
  Future<void> addPost(Post post) async {
    try {
      final postJson = post.toJson();
      postJson.remove('id');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postJson),
      );

      if (response.statusCode == 201) {
        final newPost = Post.fromJson(json.decode(response.body));
        posts.add(newPost);
        print("Post added: ${newPost.content} with id: ${newPost.id}");
      } else {
        print("Failed to add post: ${response.statusCode}");
        throw Exception('Failed to add post');
      }
    } catch (e) {
      print("Error adding post: $e");
    }
  }

  @action
  Future<void> likePost(Post post) async {
    try {
      post.likes++;
      final url = '$apiUrl/${post.id}';
      print(
          "Liking post with URL: $url and payload: ${json.encode(post.toJson())}");
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200) {
        posts = ObservableList<Post>.of(posts);
        print("Post liked: ${post.content}");
      } else {
        print("Failed to like post: ${response.statusCode}");
      }
    } catch (e) {
      print("Error liking post: $e");
    }
  }

  @action
  Future<void> addComment(Post post, String comment) async {
    try {
      post.comments.add(comment);
      final url = '$apiUrl/${post.id}';
      print(
          "Adding comment to post with URL: $url and payload: ${json.encode(post.toJson())}");
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );

      if (response.statusCode == 200) {
        posts = ObservableList<Post>.of(posts);
        print("Comment added to post: ${post.content}");
      } else {
        print("Failed to add comment: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }
}
