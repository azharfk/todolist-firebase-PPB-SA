import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_todolist/model/item_list.dart';
import 'package:firebase_todolist/model/todo.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'plan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool isComplete = false;

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<QuerySnapshot>? searchResultsFuture;

  Future<void> searchResult(String textEntered) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("Todos")
        .where("title", isGreaterThanOrEqualTo: textEntered)
        .where("title", isLessThan: textEntered + 'z')
        .get();

    setState(() {
      searchResultsFuture = Future.value(querySnapshot);
    });
  }

  void clearText() {
    _titleController.clear();
    _descriptionController.clear();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> addTodo() {
    CollectionReference todoCollection = _firestore.collection('Todos');
    return todoCollection.add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'isComplete': isComplete,
      'uid': _auth.currentUser!.uid,
    }).catchError((error) {
      print('Failed to add todo: $error');
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    searchResultsFuture = null;
                  });
                } else {
                  searchResult(value);
                }
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _searchController.text.isEmpty
                  ? _firestore
                      .collection('Todos')
                      .where('uid', isEqualTo: user!.uid)
                      .snapshots()
                  : searchResultsFuture != null
                      ? searchResultsFuture!
                          .asStream()
                          .cast<QuerySnapshot<Map<String, dynamic>>>()
                      : Stream.empty(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Todo> listTodo = snapshot.data!.docs.map((document) {
                  final data = document.data();
                  return Todo.fromMap(data);
                }).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: listTodo.length,
                  itemBuilder: (context, index) {
                    return ItemList(
                      todo: listTodo[index],
                      transaksiDocId: snapshot.data!.docs[index].id,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              todo: listTodo[index],
                              docId: snapshot.data!.docs[index].id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_todo',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tambah Todo'),
                  content: SizedBox(
                    width: 200,
                    height: 100,
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration:
                              const InputDecoration(hintText: 'Judul todo'),
                        ),
                        TextField(
                          controller: _descriptionController,
                          decoration:
                              const InputDecoration(hintText: 'Deskripsi todo'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Batalkan'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('Tambah'),
                      onPressed: () {
                        addTodo();
                        clearText();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'plan_page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlanPage()),
              );
            },
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }
}
