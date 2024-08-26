import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo.dart';

class ItemList extends StatelessWidget {
  final Todo todo;
  final String transaksiDocId;
  final VoidCallback
      onTap; // Menambahkan parameter onTap untuk menerima callback

  const ItemList({
    super.key,
    required this.todo,
    required this.transaksiDocId,
    required this.onTap, // Menambahkan parameter onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Menggunakan onTap saat item ditekan
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    todo.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    todo.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                todo.isComplete
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: todo.isComplete ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Todos')
                    .doc(transaksiDocId)
                    .update({'isComplete': !todo.isComplete});
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Todos')
                    .doc(transaksiDocId)
                    .delete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
