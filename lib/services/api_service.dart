import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/todo.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';
  static const String localPostsKey = 'local_posts';
  
  // Cache of created posts by user ID
  static final Map<int, List<Post>> _createdPostsCache = {};
  
  // Add a post to the local cache and persist to SharedPreferences
  static Future<void> _addPostToCache(Post post) async {
    if (!_createdPostsCache.containsKey(post.userId)) {
      _createdPostsCache[post.userId] = [];
    }
    _createdPostsCache[post.userId]!.add(post);
    
    // Save to SharedPreferences
    await _saveLocalPosts();
  }
  
  // Initialize cache from SharedPreferences
  static Future<void> initializeLocalPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? localPostsJson = prefs.getString(localPostsKey);
    
    if (localPostsJson != null) {
      try {
        final Map<String, dynamic> postsData = jsonDecode(localPostsJson);
        
        postsData.forEach((userId, posts) {
          final int userIdInt = int.parse(userId);
          _createdPostsCache[userIdInt] = (posts as List)
              .map((postJson) => Post.fromJson(postJson))
              .toList();
        });
      } catch (e) {
        print('Error loading local posts: $e');
      }
    }
  }
  
  // Save cache to SharedPreferences
  static Future<void> _saveLocalPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert cache to JSON-compatible format
      final Map<String, dynamic> postsData = {};
      _createdPostsCache.forEach((userId, posts) {
        postsData[userId.toString()] = posts.map((post) => post.toJson()).toList();
      });
      
      await prefs.setString(localPostsKey, jsonEncode(postsData));
    } catch (e) {
      print('Error saving local posts: $e');
    }
  }

  Future<Map<String, dynamic>> getUsers({int skip = 0, int limit = 10, String? search}) async {
    final queryParams = {
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    Uri uri;
    
    // Use the search endpoint if search is provided
    if (search != null && search.isNotEmpty) {
      uri = Uri.parse('$baseUrl/users/search').replace(queryParameters: {'q': search, ...queryParams});
    } else {
      uri = Uri.parse('$baseUrl/users').replace(queryParameters: queryParams);
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'users': (data['users'] as List).map((json) => User.fromJson(json)).toList(),
        'total': data['total'],
      };
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User> getUserById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<List<Post>> getUserPosts(int userId, {int skip = 0, int limit = 10}) async {
    final queryParams = {
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    
    final uri = Uri.parse('$baseUrl/posts/user/$userId').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> data = responseData['posts'];
      final int total = responseData['total'] ?? data.length;
      
      List<Post> posts = data.map((json) => Post.fromJson(json)).toList();
      
      // Add locally created posts to the results, but only on the first page
      if (skip == 0 && _createdPostsCache.containsKey(userId)) {
        posts = [..._createdPostsCache[userId]!, ...posts];
      }
      
      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<Todo>> getUserTodos(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/todos/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['todos'];
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<Post> createPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    // Create an ID for the local post (negative to avoid conflicts with API)
    final int localId = -DateTime.now().millisecondsSinceEpoch;
    
    // Create tags array (empty by default)
    final List<String> tags = [];
    
    // Default reactions
    final Map<String, int> reactions = {
      'likes': 0,
      'dislike': 0
    };
    
    try {
      // Try to send to server
      final response = await http.post(
        Uri.parse('$baseUrl/posts/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'title': title,
          'body': body,
          'tags': tags,
          'reactions': reactions
        }),
      );
      
      // If successful, use the server response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final Post newPost = Post.fromJson(data);
        await _addPostToCache(newPost);
        return newPost;
      }
      
      // If server request failed, create a local post
      print('Server request failed, creating local post');
    } catch (e) {
      // Network error or other exception, create a local post
      print('Network error: $e - creating local post');
    }
    
    // Create a local post with the generated ID
    final Post localPost = Post(
      id: localId,
      userId: userId,
      title: title,
      body: body,
      tags: tags,
      reactions: reactions,
    );
    
    // Save to local cache and persist
    await _addPostToCache(localPost);
    return localPost;
  }
} 