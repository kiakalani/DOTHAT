import 'package:dothat/storage.dart';
import 'package:flutter/material.dart';
import 'taskDetails.dart';

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
  bool isSelected;
  DateTime? dueDate;
  String? status;
  String? importance;
  DateTime? reminders;

  Task(
      {required this.name,
      this.isSelected = false,
      this.dueDate,
      this.status,
      this.importance,
      this.reminders});
}

class _HomePageState extends State<HomePage> {
  bool _isEditingListName = false;
  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  /// <summary>
  /// Loads all of the categories into the lists instance when called
  /// </summary>
  Future<void> loadCategories() async {
    var l = await TodoDB().getCategories();
    Map<String, List<dynamic>> tasks = {};
    for (int i = 0; i < l.length; i++) {
      tasks[l[i]['name']] = await TodoDB().getItems(l[i]['name']);
    }
    setState(() {
      lists = l
          .map((e) => CategoryList(
              name: e['name'],
              tasks:
                  tasks[e['name']]!.map((j) => Task(name: j['name'])).toList()))
          .toList();
      listNameController.clear();
      _isAddingNewList = false;
    });
  }

  /// <summary>
  /// Adds the new category to the database and if successful, it would
  /// then update the display to show the new category
  /// </summary>
  void addNewCategory(String name) {
    TodoDB().addCategory(name).then((value) => {
          if (value)
            {
              setState(() {
                lists.add(CategoryList(name: name, tasks: []));
                listNameController.clear();
                _isAddingNewList = false;
              })
            }
        });
  }

  /// <summary>
  /// Removes the category at the given index from the database and the
  /// view.
  /// </summary>
  void removeCategory(int index) {
    TodoDB().deleteCategory(lists[index].name).then((value) => {
          setState(() {
            lists.removeAt(index);
          })
        });
  }

  /// <summary>
  /// Adds an item to the provided category.
  /// </summary>
  void addItem(CategoryList l, String name) {
    TodoDB().addItem(name, l.name).then((value) {
      if (value) {
        setState(() {
          l.tasks.add(Task(name: name));
          taskNameController.clear();
          _isAddingNewTask = false;
        });
      }
    });
  }

  /// <summary>
  /// Removes an item from the category.
  /// </summary>
  void removeItem(CategoryList l, int i) {
    TodoDB().deleteItem(l.tasks[i].name, l.name).then(
      (value) {
        setState(() {
          l.tasks.removeAt(i);
        });
      },
    );
  }

  // List<CategoryList> lists = [];

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
  TextEditingController listNameControllerInTask = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: _buildTitle(),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // show list of tasks in a category
                ...lists.isEmpty ? [] : List.generate(lists[_selectedIndex].tasks.length, (index) {
                  return ListTile(
                    title: Text(lists[_selectedIndex].tasks[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetails(
                              task: lists[_selectedIndex].tasks[index]),
                        ),
                      );
                    },
                    leading: Checkbox(
                      value: lists[_selectedIndex].tasks[index].isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          lists[_selectedIndex].tasks[index].isSelected =
                              value!;
                        });
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        print(
                          "Remove task: ${lists[_selectedIndex].tasks[index].name} from list ${lists[_selectedIndex].name}");
                        removeItem(lists[_selectedIndex], index);
                        // setState(() {
                        //   lists[_selectedIndex].tasks.removeAt(index);
                        // });
                      },
                    ),
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
                if (value.isNotEmpty) {
                  print("Add task: $value");
                  addItem(lists[_selectedIndex], value);
                }
              },
              toggleAdding: () => setState(() {
                    _isAddingNewTask = true;
                  }))
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return _isEditingListName
      ? TextField(
          controller: listNameControllerInTask,
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              print("List name is changed to $value");
              setState(() {
                lists[_selectedIndex].name = value;
              });
            }
            setState(() {
              _isEditingListName = false;
            });
          },
        )
      : InkWell(
          onTap: () {
            setState(() {
              listNameControllerInTask.text = lists[_selectedIndex].name;
              _isEditingListName = true;
            });
          },
          child: Text(
            lists.isNotEmpty 
              ? 
              lists[_selectedIndex].name 
              : '',
              style: TextStyle(fontSize: 24),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        print("Remove list: ${lists[index].name}");
                        removeCategory(index);
                      },
                    ),
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
                  print("Add list: $value");
                  addNewCategory(value);
                }
              },
              toggleAdding: () => setState(() {
                    _isAddingNewList = true;
                  }))
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
