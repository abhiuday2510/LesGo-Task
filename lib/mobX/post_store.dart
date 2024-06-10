import 'package:mobx/mobx.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post_model.dart';
import '../models/user_model.dart';

part 'post_store.g.dart';

class PostStore = _PostStore with _$PostStore;

abstract class _PostStore with Store {
  static const apiUrl = 'http://192.168.1.11:3000';

  @observable
  ObservableList<Post> posts = ObservableList<Post>();

  @observable
  ObservableMap<String, User> users = ObservableMap<String, User>();

  @action
  Future<void> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/posts'));
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
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        List<dynamic> userList = json.decode(response.body);
        users = ObservableMap<String, User>.of(
          {
            for (var u in userList)
              u['id'] as String: User.fromJson(u as Map<String, dynamic>)
          },
        );
        print("Fetched users: ${users.length}");
      } else {
        print("Failed to fetch users: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @action
  Future<void> addPost(Post post) async {
    try {
      final postJson = post.toJson();
      postJson.remove('id');

      final response = await http.post(
        Uri.parse('$apiUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postJson),
      );

      if (response.statusCode == 201) {
        final decodedJson = json.decode(response.body);
        final newPost = Post.fromJson(decodedJson);
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
  Future<void> followUser(String userId) async {
    try {
      final user = users[userId];
      if (user != null) {
        user.followers++;
        final url = '$apiUrl/users/$userId';
        final response = await http.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toJson()),
        );

        if (response.statusCode == 200) {
          users[userId] = User.fromJson(json.decode(response.body));
          print("User followed: ${user.name}");
        } else {
          print("Failed to follow user: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error following user: $e");
    }
  }

  @action
  Future<void> unfollowUser(String userId) async {
    try {
      final user = users[userId];
      if (user != null) {
        user.followers--;
        final url = '$apiUrl/users/$userId';
        final response = await http.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toJson()),
        );

        if (response.statusCode == 200) {
          users[userId] = User.fromJson(json.decode(response.body));
          print("User unfollowed: ${user.name}");
        } else {
          print("Failed to unfollow user: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error unfollowing user: $e");
    }
  }

  @action
  Future<void> likePost(Post post) async {
    try {
      post.likes++;
      final url = '$apiUrl/posts/${post.id}';
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
      final url = '$apiUrl/posts/${post.id}';
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
