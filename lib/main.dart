import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "To-Do List",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> todos = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ----- LOAD DATA FROM SHARED PREFERENCES -----
  void loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("todos");

    if (jsonString != null) {
      setState(() {
        todos = List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      });
    }
  }

  // ----- SAVE DATA -----
  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("todos", jsonEncode(todos));
  }

  // ----- ADD TO-DO -----
  void addTodo() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add Task"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter task name"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  todos.add({
                    "title": controller.text,
                    "isDone": false,
                  });
                });
                saveData();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }

  // ----- TOGGLE CHECK -----
  void toggleDone(int index) {
    setState(() {
      todos[index]["isDone"] = !todos[index]["isDone"];
    });
    saveData();
  }

  // ----- DELETE TASK -----
  void deleteTask(int index) {
    setState(() {
      todos.removeAt(index);
    });
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text(
                "No tasks yet.\nTap + to add one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final t = todos[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: t["isDone"],
                      onChanged: (val) => toggleDone(index),
                    ),
                    title: Text(
                      t["title"],
                      style: TextStyle(
                        decoration: t["isDone"]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: t["isDone"] ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteTask(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
