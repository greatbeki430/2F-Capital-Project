import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_chat_app/pages/todo.dart';
import 'todo_provider.dart';

class TodoRoom extends StatefulWidget {
  const TodoRoom({super.key});

  @override
  _TodoRoomState createState() => _TodoRoomState();
}

class _TodoRoomState extends State<TodoRoom> {
  bool isGridView = true;

  void toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  void addNewTodo() {
    final todo = Todo(
      id: DateTime.now().toString(),
      title: 'New Todo',
      color: 'white', // Default color
    );
    Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO LISTS'),
        actions: [
          IconButton(icon: const Icon(Icons.grid_view), onPressed: toggleView),
          IconButton(icon: const Icon(Icons.add), onPressed: addNewTodo),
        ],
      ),
      body: isGridView
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
              ),
              itemCount: todoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return Card(
                  color:
                      todo.color == 'white' ? Colors.white : Colors.blueAccent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(todo.title),
                      IconButton(
                        icon: Icon(
                            todo.isPinned ? Icons.star : Icons.star_border),
                        onPressed: () {
                          todo.isPinned = !todo.isPinned;
                          todoProvider.updateTodo(todo);
                        },
                      ),
                      // Color selection for each todo
                      DropdownButton<String>(
                        value: todo.color,
                        onChanged: (String? newColor) {
                          if (newColor != null) {
                            setState(() {
                              todo.color = newColor;
                              todoProvider.updateTodo(todo);
                            });
                          }
                        },
                        items: <String>['white', 'red', 'blue']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            )
          : ListView.builder(
              itemCount: todoProvider.todos.length,
              itemBuilder: (context, index) {
                final todo = todoProvider.todos[index];
                return ListTile(
                  title: Text(todo.title),
                  trailing: IconButton(
                    icon: Icon(todo.isPinned ? Icons.star : Icons.star_border),
                    onPressed: () {
                      todo.isPinned = !todo.isPinned;
                      todoProvider.updateTodo(todo);
                    },
                  ),
                );
              },
            ),
    );
  }
}
