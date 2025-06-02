import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final int userId;
  final String todo;
  final bool completed;

  const Todo({
    required this.id,
    required this.userId,
    required this.todo,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] is int ? json['userId'] : int.parse(json['userId'].toString()),
      todo: json['todo'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'todo': todo,
      'completed': completed,
    };
  }

  Todo copyWith({
    int? id,
    int? userId,
    String? todo,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [id, userId, todo, completed];
} 