// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PostStore on _PostStore, Store {
  late final _$postsAtom = Atom(name: '_PostStore.posts', context: context);

  @override
  ObservableList<Post> get posts {
    _$postsAtom.reportRead();
    return super.posts;
  }

  @override
  set posts(ObservableList<Post> value) {
    _$postsAtom.reportWrite(value, super.posts, () {
      super.posts = value;
    });
  }

  late final _$fetchPostsAsyncAction =
      AsyncAction('_PostStore.fetchPosts', context: context);

  @override
  Future<void> fetchPosts() {
    return _$fetchPostsAsyncAction.run(() => super.fetchPosts());
  }

  late final _$addPostAsyncAction =
      AsyncAction('_PostStore.addPost', context: context);

  @override
  Future<void> addPost(Post post) {
    return _$addPostAsyncAction.run(() => super.addPost(post));
  }

  late final _$likePostAsyncAction =
      AsyncAction('_PostStore.likePost', context: context);

  @override
  Future<void> likePost(Post post) {
    return _$likePostAsyncAction.run(() => super.likePost(post));
  }

  late final _$addCommentAsyncAction =
      AsyncAction('_PostStore.addComment', context: context);

  @override
  Future<void> addComment(Post post, String comment) {
    return _$addCommentAsyncAction.run(() => super.addComment(post, comment));
  }

  @override
  String toString() {
    return '''
posts: ${posts}
    ''';
  }
}
