import 'package:flutter/material.dart';

class Task {
  final String name;
  final String comment;
  final String category;

  Task({required this.name, required this.comment, required this.category});
}

List<Task> tasks = [];
List<bool> taskActiveStates = [];

void main() => runApp(const NavigationBarApp());

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Navigation());
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;
  String pageTitle = 'Home';

  final List<String> categories = ['Дом', 'Работа', 'Семья'];

  void _addTask(String name, String comment, String category) {
    setState(() {
      tasks.add(Task(name: name, comment: comment, category: category));
      taskActiveStates.add(true);
    });
  }

  void _updatePageTitle(int index) {
    setState(() {
      currentPageIndex = index;
      switch (index) {
        case 0:
          pageTitle = 'Дом';
          break;
        case 1:
          pageTitle = 'Работа';
          break;
        case 2:
          pageTitle = 'Семья';
          break;
        case 3:
          pageTitle = 'Профиль';
          break;
        default:
          pageTitle = '';
      }
    });
  }

  List<Task> getFilteredTasks() {
    if (currentPageIndex < 3) {
      return tasks.where((task) => task.category == categories[currentPageIndex]).toList();
    }
    return tasks;
  }

  List<bool> getFilteredStates() {
    if (currentPageIndex < 3) {
      List<bool> filteredStates = [];
      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i].category == categories[currentPageIndex]) {
          filteredStates.add(taskActiveStates[i]);
        }
      }
      return filteredStates;
    }
    return taskActiveStates;
  }

  Widget _buildBody() {
    switch (currentPageIndex) {
      case 0:
      case 1:
      case 2:
        return HomePage(
          tasks: getFilteredTasks(),
          taskStates: getFilteredStates(),
          onToggle: _toggleTaskState,
          currentCategory: categories[currentPageIndex],
          allTasks: tasks,
          allStates: taskActiveStates,
        );
      case 3:
        return const Profil();
      default:
        return const SizedBox.shrink();
    }
  }

  void _toggleTaskState(int filteredIndex, bool value) {
    setState(() {
      if (currentPageIndex < 3) {
        int realIndex = -1;
        int categoryCount = -1;
        for (int i = 0; i < tasks.length; i++) {
          if (tasks[i].category == categories[currentPageIndex]) {
            categoryCount++;
            if (categoryCount == filteredIndex) {
              realIndex = i;
              break;
            }
          }
        }
        if (realIndex != -1) {
          taskActiveStates[realIndex] = value;
        }
      } else {
        taskActiveStates[filteredIndex] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WritePage(
                onSave: (name, comment, category) {
                  _addTask(name, comment, category);
                  Navigator.pop(context);
                },
                initialCategory: currentPageIndex < 3 ? categories[currentPageIndex] : 'Дом',
              ),
            ),
          );
        },
        child: const Icon(Icons.bolt),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          _updatePageTitle(index);
        },
        indicatorColor: Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Дом',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.work),
            icon: Icon(Icons.work_outline),
            label: 'Работа',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.people),
            icon: Icon(Icons.people_outline),
            label: 'Семья',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Пользователь',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}

class WritePage extends StatelessWidget {
  final Function(String, String, String)? onSave;
  final String initialCategory;

  const WritePage({super.key, this.onSave, required this.initialCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая задача')),
      body: AddTaskForm(
        onSave: onSave,
        initialCategory: initialCategory,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Task> tasks;
  final List<bool> taskStates;
  final Function(int, bool) onToggle;
  final String currentCategory;
  final List<Task> allTasks;
  final List<bool> allStates;

  const HomePage({
    super.key,
    required this.tasks,
    required this.taskStates,
    required this.onToggle,
    required this.currentCategory,
    required this.allTasks,
    required this.allStates,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text('Нет задач в категории $currentCategory'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isActive = taskStates[index];

        return Container(
          color: isActive ? Colors.green[100] : Colors.grey[400],
          child: ListTile(
            title: Text(task.name),
            subtitle: Text(
              task.comment,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            trailing: Switch(
              value: isActive,
              onChanged: (value) {
                onToggle(index, value);
              },
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

class Profil extends StatelessWidget {
  const Profil({super.key});
  @override
  Widget build(BuildContext context) {
    int homeCount = tasks.where((t) => t.category == 'Дом').length;
    int workCount = tasks.where((t) => t.category == 'Работа').length;
    int familyCount = tasks.where((t) => t.category == 'Семья').length;
    int totalTasks = tasks.length;
    int completedTasks = taskActiveStates.where((state) => !state).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 100, color: Colors.blue),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: const Text('Задачи по разделам'),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('Дом', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('$homeCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  Text('Работа', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('$workCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  Text('Семья', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('$familyCount', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: const Text('Итог'),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(children: [
                Text('Всего задач', style: TextStyle(fontSize: 16)),
                Text('Выполнено', style: TextStyle(fontSize: 16)),
              ]),
              Column(children: [
                Text('$totalTasks', style: TextStyle(fontSize: 16)),
                Text('$completedTasks', style: TextStyle(fontSize: 16)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

class AddTaskForm extends StatefulWidget {
  final Function(String, String, String)? onSave;
  final String initialCategory;

  const AddTaskForm({
    super.key,
    this.onSave,
    required this.initialCategory
  });

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  TextEditingController? _nameController;
  TextEditingController? _commentController;

  final List<String> _categories = ['Дом', 'Работа', 'Семья'];
  late String _selectedCategory;

  String _titleInput = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _commentController = TextEditingController();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _commentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 250,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Название задачи',
              ),
              onChanged: (value) {
                _titleInput = value;
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: const Text('Категория:'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _categories
                .map((category) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: category,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(category),
                ],
              ),
            ))
                .toList(),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: const Text('Комментарий:'),
          ),
          SizedBox(
            width: 250,
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (widget.onSave != null) {
                widget.onSave!(_nameController!.text, _commentController!.text, _selectedCategory);
              }
            },
            child: const Text('Сохранить'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}