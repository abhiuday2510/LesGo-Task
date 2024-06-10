import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'post_store.dart';
import 'post_model.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final postStore = Provider.of<PostStore>(context);
    postStore.fetchPosts(); // Ensure posts are fetched when the screen is built

    return Scaffold(
      appBar: AppBar(
        title: Text('Social Media App'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () => _addPost(context, postStore),
          )
        ],
      ),
      body: Observer(
        builder: (_) {
          print("Post list updated with ${postStore.posts.length} posts");
          return ListView.builder(
            itemCount: postStore.posts.length,
            itemBuilder: (context, index) {
              final post = postStore.posts[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/user_avatar.png'),
                      ),
                      title: Text('User Name'),
                      subtitle: Text('Location'),
                    ),
                    if (post.imageUrl != null) Image.file(File(post.imageUrl!)),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(post.content),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up),
                          onPressed: () => postStore.likePost(post),
                        ),
                        Text('${post.likes}'),
                        IconButton(
                          icon: Icon(Icons.comment),
                          onPressed: () =>
                              _addComment(context, postStore, post),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var comment in post.comments)
                            Text(
                              comment,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addPost(BuildContext context, PostStore postStore) {
    final contentController = TextEditingController();
    final ImagePicker picker = ImagePicker();
    String? imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(hintText: 'Enter content'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          imageUrl = pickedFile.path;
                        });
                      }
                    },
                    child: Text('Pick Image'),
                  ),
                  SizedBox(height: 10),
                  if (imageUrl != null) Image.file(File(imageUrl!)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    final newPost = Post(
                      id: "",
                      content: contentController.text,
                      imageUrl: imageUrl,
                      likes: 0,
                      comments: [],
                    );
                    print("Adding post: ${newPost.content}");
                    postStore.addPost(newPost).then((_) {
                      print("Post added successfully");
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      print("Failed to add post: $error");
                    });
                  },
                  child: Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addComment(BuildContext context, PostStore postStore, Post post) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Enter comment'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                postStore.addComment(post, commentController.text).then((_) {
                  print("Comment added successfully");
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print("Failed to add comment: $error");
                });
              },
              child: Text('Add Comment'),
            ),
          ],
        );
      },
    );
  }
}
