import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/todo_model.dart';
import '../veiw_model/todo_view_model.dart';

class TodoView extends ConsumerWidget {
  const TodoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodos);
    final newTodoController = TextEditingController();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              DrawerHeader(
                child: Text('メニュー'),
              ),
              SizedBox(
                height: 24,
              ),
              Text(
                "一般",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Divider(),
              ListTile(
                title: Text('他のユーザーと共有'),
              ),
              Divider(),
              ListTile(
                title: Text('アカウント設定'),
              ),
              Divider(),
              SizedBox(
                height: 24,
              ),
              Text("このアプリについて",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Divider(),
              ListTile(
                title: Text('クレジット'),
              ),
              Divider(),
              ListTile(
                title: Text('利用規約'),
              ),
              Divider(),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            TextField(
              controller: newTodoController,
              decoration: const InputDecoration(
                labelText: 'なにをしないといけない？',
              ),
              onSubmitted: (value) {
                ref.read(todoListProvider.notifier).add(value);
                newTodoController.clear();
              },
            ),
            const SizedBox(height: 42),
            Toolbar(),
            if (todos.isNotEmpty) const Divider(height: 0),
            for (var i = 0; i < todos.length; i++) ...[
              if (i > 0) const Divider(height: 0),
              Dismissible(
                key: ValueKey(todos[i].id),
                onDismissed: (_) {
                  ref.read(todoListProvider.notifier).remove(todos[i]);
                },
                child: ProviderScope(overrides: [
                  _currentTodo.overrideWithValue(todos[i]),
                ], child: TodoItem()),
              )
            ],
          ],
        ),
      ),
    );
  }
}

class Toolbar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoListFilter);
    Color? textColorFor(TodoListFilter value) {
      return filter == value ? Colors.blue : Colors.black;
    }

    return Material(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
            child: Text(
          '${ref.watch(uncompletedTodosCount)} コ残ってる',
          overflow: TextOverflow.ellipsis,
        )),
        TextButton(
          onPressed: () =>
              ref.read(todoListFilter.notifier).state = TodoListFilter.all,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            foregroundColor:
                MaterialStateProperty.all(textColorFor(TodoListFilter.all)),
          ),
          child: const Text('all'),
        ),
        TextButton(
          onPressed: () =>
              ref.read(todoListFilter.notifier).state = TodoListFilter.active,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            foregroundColor:
                MaterialStateProperty.all(textColorFor(TodoListFilter.active)),
          ),
          child: const Text('active'),
        ),
        TextButton(
          onPressed: () => ref.read(todoListFilter.notifier).state =
              TodoListFilter.completed,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            foregroundColor: MaterialStateProperty.all(
                textColorFor(TodoListFilter.completed)),
          ),
          child: const Text('completed'),
        )
      ]),
    );
  }
}

final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

class TodoItem extends ConsumerWidget {
  const TodoItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    final itemFocusNode = FocusNode();
    final itemIsFocused = itemFocusNode.hasFocus;

    final textEditingController = TextEditingController();
    final textFieldFocusNode = FocusNode();
    return Material(
        color: Colors.white,
        elevation: 6,
        child: Focus(
          focusNode: itemFocusNode,
          onFocusChange: (focused) {
            if (focused) {
              textEditingController.text = todo.description;
            } else {
              ref
                  .read(todoListProvider.notifier)
                  .edit(id: todo.id, description: textEditingController.text);
            }
          },
          child: ListTile(
            leading: Checkbox(
              value: todo.completed,
              onChanged: (value) =>
                  ref.read(todoListProvider.notifier).toggle(todo.id),
            ),
            title: itemIsFocused
                ? TextField(
                    autofocus: true,
                    focusNode: textFieldFocusNode,
                    controller: textEditingController,
                  )
                : Text(todo.description),
          ),
        ));
  }
}
