import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'mobX/post_store.dart';
import 'models/post_model.dart';
import 'models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, bool> followStatus = {};

  @override
  void initState() {
    super.initState();
    final postStore = Provider.of<PostStore>(context, listen: false);
    postStore.fetchPosts();
    postStore.fetchUsers();
  }

  void toggleFollowStatus(
      String userId, bool isFollowing, PostStore postStore) {
    setState(() {
      followStatus[userId] = !isFollowing;
    });

    if (isFollowing) {
      postStore.unfollowUser(userId);
    } else {
      postStore.followUser(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postStore = Provider.of<PostStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) => Text(
              '${widget.user.name} : ${postStore.users[widget.user.id]?.followers ?? widget.user.followers} followers'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => _addPost(context, postStore),
          )
        ],
      ),
      body: Observer(
        builder: (_) {
          return ListView.builder(
            itemCount: postStore.posts.length,
            itemBuilder: (context, index) {
              final post = postStore.posts[index];
              final postUser = postStore.users[post.userId];

              if (postUser == null) return Container();

              bool isFollowing =
                  followStatus[post.userId] ?? (postUser.followers > 0);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundImage:
                            NetworkImage("https://placehold.co/600x400.png"),
                      ),
                      title: Text(postUser.name),
                      subtitle: const Text('Location'),
                      trailing: post.userId != widget.user.id
                          ? ElevatedButton(
                              onPressed: () => toggleFollowStatus(
                                  post.userId, isFollowing, postStore),
                              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                            )
                          : null,
                    ),
                    if (post.imageUrl != null) Image.file(File(post.imageUrl!)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(post.content),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () => postStore.likePost(post),
                        ),
                        Text('${post.likes}'),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () =>
                              _addComment(context, postStore, post, postUser),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () => _sharePost(post),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var comment in post.comments)
                            Text(
                              comment,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
              title: const Text('Add Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contentController,
                    decoration:
                        const InputDecoration(hintText: 'Enter content'),
                  ),
                  const SizedBox(height: 10),
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
                    child: const Text('Pick Image'),
                  ),
                  const SizedBox(height: 10),
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
                      userId: widget.user.id,
                    );
                    postStore.addPost(newPost).then((_) {
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      print("Failed to add post: $error");
                    });
                  },
                  child: const Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addComment(
      BuildContext context, PostStore postStore, Post post, User? postUser) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: 'Enter comment'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                postStore
                    .addComment(
                        post, "${widget.user.name} : ${commentController.text}")
                    .then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print("Failed to add comment: $error");
                });
              },
              child: const Text('Add Comment'),
            ),
          ],
        );
      },
    );
  }

  void _sharePost(Post post) {
    if (post.imageUrl != null) {
      Share.shareXFiles([XFile(post.imageUrl!)], text: post.content);
    } else {
      Share.share(post.content);
    }
  }
}
