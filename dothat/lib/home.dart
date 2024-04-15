import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class CategoryList {
  String name;
  List<Task> tasks;

  CategoryList({required this.name, required this.tasks});
}

class Task {
  String name;
  String? dueDate;
  String? status;
  String? importance;
  String? reminders;

  Task(
      {required this.name,
      this.dueDate,
      this.status,
      this.importance,
      this.reminders});
}

class _HomePageState extends State<HomePage> {
  List<CategoryList> lists = [
    CategoryList(
        name: 'Groceries',
        tasks: [Task(name: 'Apples'), Task(name: 'Bananas')]),
    CategoryList(
        name: 'Homework', tasks: [Task(name: 'Math'), Task(name: 'Science')]),
  ];
  int _selectedIndex = 0;
  bool _isAddingNewList = false;
  bool _isAddingNewTask = false;
  TextEditingController listNameController = TextEditingController();
  TextEditingController taskNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // show list of tasks in a category
                ...List.generate(lists[_selectedIndex].tasks.length, (index) {
                  return ListTile(
                    title: Text(lists[_selectedIndex].tasks[index].name),
                  );
                }),
              ],
            ),
          ),
          _addNewItem(
            isAdding: _isAddingNewTask, 
            textController: taskNameController,
            hintText: "+ Add New Task", 
            onAdd: (String value) {
              setState(() {
                lists[_selectedIndex].tasks.add(Task(name: value));
                _isAddingNewTask = false;
              });
            },
            toggleAdding: () => setState(() {
              _isAddingNewTask = true;
            })
          )
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
        child: Column(
          children: [
            // display Do that
            Container(
              height: 100,
              color: const Color(0xFF0ABAB5),
              child: const Padding(
                padding: EdgeInsets.only(top: 45),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Do that',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ))),
            Expanded(
              child: ListView(
                children: [
                  // show list of categories
                  ...List.generate(lists.length, (index) {
                    return ListTile(
                      title: Text(lists[index].name),
                      selected: index == _selectedIndex,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
            _addNewItem(
              isAdding: _isAddingNewList, 
              textController: listNameController, 
              hintText: "+ New List", 
              onAdd: (String value) {
                if (value.isNotEmpty) {
                  setState(() {
                    lists.add(CategoryList(name: value, tasks: []));
                    _isAddingNewList = false;
                  });
                }
              },
              toggleAdding: () => setState(() {
                _isAddingNewList = true;
              })
            )
          ],
        ),
      );
  }

  // add new list or task to the list
  Widget _addNewItem({
    required bool isAdding,
    required TextEditingController textController,
    required String hintText,
    required Function(String) onAdd,
    required VoidCallback toggleAdding,
  }) {
    return ListTile(
      title: isAdding
          // allow user to enter new item name
          ? TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.done),
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      onAdd(textController.text);
                      textController.clear;
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  onAdd(textController.text);
                  textController.clear;
                }
              },
            )
          : Text(hintText),
      onTap: () {
        if (!isAdding) {
         toggleAdding();
        }
      },
    );
  }
}









