import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mobX/post_store.dart';
import 'user_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PostStore>(create: (_) => PostStore()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social Media App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Initializer(),
      ),
    );
  }
}

class Initializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final postStore = Provider.of<PostStore>(context, listen: false);

    return FutureBuilder(
      future: postStore.fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading users'));
        } else {
          return UserSelectionScreen();
        }
      },
    );
  }
}
