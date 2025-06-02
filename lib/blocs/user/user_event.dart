import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {
  final int skip;
  final int limit;
  final String? search;

  const LoadUsers({
    this.skip = 0,
    this.limit = 10,
    this.search,
  });

  @override
  List<Object?> get props => [skip, limit, search];
}

class SearchUsers extends UserEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadUserDetails extends UserEvent {
  final int userId;

  const LoadUserDetails(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadMoreUserPosts extends UserEvent {
  final int userId;
  final int skip;
  final int limit;

  const LoadMoreUserPosts({
    required this.userId,
    required this.skip,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [userId, skip, limit];
}

class RefreshUsers extends UserEvent {
  const RefreshUsers();
} 