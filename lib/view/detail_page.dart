import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_todolist/model/todo.dart';

class DetailPage extends StatefulWidget {
  final Todo todo;
  final String docId;

  const DetailPage({super.key, required this.todo, required this.docId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.todo.title;
    _descriptionController.text = widget.todo.description;
    isComplete = widget.todo.isComplete;
  }

  Future<void> _updateTodo() async {
    await FirebaseFirestore.instance
        .collection('Todos')
        .doc(widget.docId)
        .update({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'isComplete': isComplete,
    });
  }

  Future<void> _deleteTodo() async {
    await FirebaseFirestore.instance
        .collection('Todos')
        .doc(widget.docId)
        .delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Todo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTodo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Complete'),
              value: isComplete,
              onChanged: (value) {
                setState(() {
                  isComplete = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateTodo();
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
