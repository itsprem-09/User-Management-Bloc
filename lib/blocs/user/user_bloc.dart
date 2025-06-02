import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/post.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ApiService _apiService;
  static const int _pageSize = 10;

  UserBloc({required ApiService apiService})
      : _apiService = apiService,
        super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<LoadUserDetails>(_onLoadUserDetails);
    on<LoadMoreUserPosts>(_onLoadMoreUserPosts);
    on<RefreshUsers>(_onRefreshUsers);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    try {
      // Only emit loading state on first load
      if (event.skip == 0) {
        // If we have current users in the state, preserve them while loading to avoid UI flash
        if (state is UsersLoaded) {
          emit(UserLoading.fromUsersLoaded(state as UsersLoaded));
        } else {
          emit(UserLoading());
        }
      }

      final result = await _apiService.getUsers(
        skip: event.skip,
        limit: event.limit,
        search: event.search,
      );

      final users = result['users'] as List<User>;
      final total = result['total'] as int;

      if (event.skip == 0) {
        emit(UsersLoaded(
          users: users,
          total: total,
          hasReachedMax: users.length >= total,
          isSearchResult: event.search != null && event.search!.isNotEmpty,
        ));
      } else {
        final currentState = state as UsersLoaded;
        final updatedUsers = [...currentState.users, ...users];
        emit(currentState.copyWith(
          users: updatedUsers,
          hasReachedMax: updatedUsers.length >= total,
        ));
      }
    } catch (e) {
      // If error occurs on initial load
      if (event.skip == 0) {
        emit(UserError(e.toString()));
      } else {
        // If error occurs during pagination, keep current state but show error
        if (state is UsersLoaded) {
          final current = state as UsersLoaded;
          emit(UserError('Failed to load more users: ${e.toString()}'));
          // After a delay, revert back to the previous state for recovery
          await Future.delayed(const Duration(seconds: 2));
          emit(current);
        } else {
          emit(UserError(e.toString()));
        }
      }
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<UserState> emit) async {
    try {
      // Keep current users while loading search
      if (state is UsersLoaded) {
        emit(UserLoading.fromUsersLoaded(state as UsersLoaded));
      } else {
        emit(UserLoading());
      }

      final result = await _apiService.getUsers(
        skip: 0,
        limit: _pageSize,
        search: event.query,
      );

      final users = result['users'] as List<User>;
      final total = result['total'] as int;

      emit(UsersLoaded(
        users: users,
        total: total,
        hasReachedMax: true, // Search results don't support pagination in API
        isSearchResult: true,
      ));
    } catch (e) {
      emit(UserError('Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserDetails(LoadUserDetails event, Emitter<UserState> emit) async {
    try {
      emit(UserLoading());
      final user = await _apiService.getUserById(event.userId);
      final posts = await _apiService.getUserPosts(event.userId, limit: _pageSize);
      final todos = await _apiService.getUserTodos(event.userId);

      emit(UserDetailsLoaded(
        user: user,
        posts: posts,
        todos: todos,
        hasReachedMaxPosts: posts.length < _pageSize,
        totalPosts: posts.length,
      ));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
  
  Future<void> _onLoadMoreUserPosts(LoadMoreUserPosts event, Emitter<UserState> emit) async {
    if (state is! UserDetailsLoaded) return;
    
    final currentState = state as UserDetailsLoaded;
    
    try {
      final newPosts = await _apiService.getUserPosts(
        event.userId, 
        skip: event.skip, 
        limit: event.limit
      );
      
      if (newPosts.isEmpty) {
        emit(currentState.copyWith(
          hasReachedMaxPosts: true
        ));
        return;
      }
      
      final updatedPosts = [...currentState.posts, ...newPosts];
      
      emit(currentState.copyWith(
        posts: updatedPosts,
        hasReachedMaxPosts: newPosts.length < event.limit,
        totalPosts: updatedPosts.length
      ));
    } catch (e) {
      // Just emit an error state with the current data preserved
      emit(UserError('Failed to load more posts: ${e.toString()}'));
      
      // After a short delay, revert back to the previous state
      await Future.delayed(const Duration(seconds: 3));
      if (state is UserError) {
        emit(currentState);
      }
    }
  }

  Future<void> _onRefreshUsers(RefreshUsers event, Emitter<UserState> emit) async {
    add(const LoadUsers(skip: 0, limit: _pageSize));
  }
} 