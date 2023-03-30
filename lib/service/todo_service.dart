import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/todo_model.dart';

final firestoreServiceProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final todoServiceProvider = Provider<TodoService>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return TodoService(firestore);
});

class TodoService {
  TodoService(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get todoCollection =>
      firestore.collection('todos');

  Future<void> create(Todo todo) async {
    await todoCollection.doc(todo.id).set(todo.toJson());
  }

  Future<void> update(Todo todo) async {
    await todoCollection.doc(todo.id).update(todo.toJson());
  }

  Future<void> delete(String id) async {
    await todoCollection.doc(id).delete();
  }

  Stream<List<Todo>> readAll(String userId) {
    return todoCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Todo.fromJson(doc.data());
      }).toList();
    });
  }
}
