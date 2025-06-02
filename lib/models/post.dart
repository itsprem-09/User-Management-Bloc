import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;
  final List<String> tags;
  final Map<String, int> reactions;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.tags,
    required this.reactions,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // Handle potential variations in the reactions field
    final Map<String, dynamic> rawReactions = Map<String, dynamic>.from(json['reactions'] ?? {});
    final Map<String, int> normalizedReactions = {};
    
    // Normalize reaction keys
    if (rawReactions.containsKey('likes')) {
      normalizedReactions['likes'] = rawReactions['likes'] is int 
          ? rawReactions['likes'] 
          : int.parse(rawReactions['likes'].toString());
    } else {
      normalizedReactions['likes'] = 0;
    }
    
    // Handle both 'dislike' and 'dislikes' spellings
    if (rawReactions.containsKey('dislike')) {
      normalizedReactions['dislike'] = rawReactions['dislike'] is int 
          ? rawReactions['dislike'] 
          : int.parse(rawReactions['dislike'].toString());
    } else if (rawReactions.containsKey('dislikes')) {
      normalizedReactions['dislike'] = rawReactions['dislikes'] is int 
          ? rawReactions['dislikes'] 
          : int.parse(rawReactions['dislikes'].toString());
    } else {
      normalizedReactions['dislike'] = 0;
    }
    
    return Post(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] is int ? json['userId'] : int.parse(json['userId'].toString()),
      title: json['title'],
      body: json['body'],
      tags: List<String>.from(json['tags'] ?? []),
      reactions: normalizedReactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'tags': tags,
      'reactions': reactions,
    };
  }

  @override
  List<Object?> get props => [id, userId, title, body, tags, reactions];
} 