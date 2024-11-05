import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo_chat_app/pages/todo.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:workmanager/workmanager.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> todos = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('todos');

  TodoProvider() {
    // Listening to real-time database changes for collaborative editing
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        todos = data.entries
            .map((entry) =>
                Todo.fromJson(Map<String, dynamic>.from(entry.value)))
            .toList();
        notifyListeners();
      }
    });

    // Initialize background worker
    _initializeBackgroundWorker();
  }

  void addTodo(Todo todo) {
    _dbRef.child(todo.id).set(todo.toJson());
    notifyListeners();
  }

  void updateTodo(Todo todo) {
    _dbRef.child(todo.id).update(todo.toJson());
  }

  void deleteTodo(String id) {
    _dbRef.child(id).remove();
  }

  void _initializeBackgroundWorker() {
    Workmanager().initialize(_backgroundTask, isInDebugMode: true);
    Workmanager().registerPeriodicTask("sync_todos", "fetchUpdates",
        frequency: Duration(minutes: 15));
  }

  static void _backgroundTask() {
    // This function runs in the background and checks for new messages or todos
    print("Background task running: syncing todos");
    // Fetch new updates and synchronize here if needed
  }
}
