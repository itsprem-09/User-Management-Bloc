import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../models/post.dart';
import '../../models/todo.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {
  // Optionally holds the current users while loading more
  final List<User>? users;
  final int? total;
  final bool? hasReachedMax;

  const UserLoading({this.users, this.total, this.hasReachedMax});

  // Factory to create loading state from current state
  factory UserLoading.fromUsersLoaded(UsersLoaded state) {
    return UserLoading(
      users: state.users,
      total: state.total,
      hasReachedMax: state.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [users, total, hasReachedMax];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UsersLoaded extends UserState {
  final List<User> users;
  final int total;
  final bool hasReachedMax;
  final bool isSearchResult;

  const UsersLoaded({
    required this.users,
    required this.total,
    this.hasReachedMax = false,
    this.isSearchResult = false,
  });

  UsersLoaded copyWith({
    List<User>? users,
    int? total,
    bool? hasReachedMax,
    bool? isSearchResult,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSearchResult: isSearchResult ?? this.isSearchResult,
    );
  }

  @override
  List<Object?> get props => [users, total, hasReachedMax, isSearchResult];
}

class UserDetailsLoaded extends UserState {
  final User user;
  final List<Post> posts;
  final List<Todo> todos;
  final bool hasReachedMaxPosts;
  final int totalPosts;

  const UserDetailsLoaded({
    required this.user,
    required this.posts,
    required this.todos,
    this.hasReachedMaxPosts = false,
    this.totalPosts = 0,
  });

  UserDetailsLoaded copyWith({
    User? user,
    List<Post>? posts,
    List<Todo>? todos,
    bool? hasReachedMaxPosts,
    int? totalPosts,
  }) {
    return UserDetailsLoaded(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      todos: todos ?? this.todos,
      hasReachedMaxPosts: hasReachedMaxPosts ?? this.hasReachedMaxPosts,
      totalPosts: totalPosts ?? this.totalPosts,
    );
  }

  @override
  List<Object?> get props => [user, posts, todos, hasReachedMaxPosts, totalPosts];
} 