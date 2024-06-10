import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'home_screen.dart';
import 'mobX/post_store.dart';

class UserSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final postStore = Provider.of<PostStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
      ),
      body: Observer(
        builder: (_) {
          if (postStore.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: postStore.users.length,
            itemBuilder: (context, index) {
              final user = postStore.users.values.toList()[index];
              return ListTile(
                title: Text('${user.name} (${user.followers} followers)'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Provider.value(
                        value: postStore,
                        child: HomeScreen(user: user),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
