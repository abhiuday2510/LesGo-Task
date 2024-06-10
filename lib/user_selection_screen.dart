import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'models/user_model.dart';
import 'mobX/post_store.dart';

class UserSelectionScreen extends StatelessWidget {
  final List<User> users = [
    User(id: "1", name: "User1"),
    User(id: "2", name: "User2"),
    User(id: "3", name: "User3"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.name),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Provider.value(
                    value: Provider.of<PostStore>(context, listen: false),
                    child: HomeScreen(user: user),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
