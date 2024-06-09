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
      ),
      body: Observer(
        builder: (_) {
          print("Post list updated with ${postStore.posts.length} posts");
          return ListView.builder(
            itemCount: postStore.posts.length,
            itemBuilder: (context, index) {
              final post = postStore.posts[index];
              return ListTile(
                title: Text(post.content),
                leading: post.imageUrl != null
                    ? Image.file(File(post.imageUrl!))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () => postStore.likePost(post),
                    ),
                    Text('${post.likes}'),
                  ],
                ),
                subtitle: Column(
                  children: [
                    for (var comment in post.comments) Text(comment),
                    TextField(
                      onSubmitted: (value) => postStore.addComment(post, value),
                      decoration: InputDecoration(hintText: 'Add a comment'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPost(context, postStore),
        child: Icon(Icons.add),
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
                        id: "0",
                        content: contentController.text,
                        imageUrl: imageUrl);
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
}
