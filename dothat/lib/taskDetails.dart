import 'package:flutter/material.dart';
import 'home.dart';

class TaskDetails extends StatefulWidget {
  final Task task;

  const TaskDetails({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isEditingName
                ? TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Enter task name",
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        print("Task name is changed to $value");
                        setState(() {
                          widget.task.name = value;
                        });
                      }
                      setState(() {
                        _isEditingName = false;
                      });
                    },
                  )
                : InkWell(
                    onTap: () {
                      setState(() {
                        _isEditingName = true;
                      });
                    },
                    child: Text(
                      '${widget.task.name}',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
            SizedBox(height: 10),
            Text('Due Date: ${widget.task.dueDate ?? "Not set"}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${widget.task.status ?? "Not set"}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Importance: ${widget.task.importance ?? "Not set"}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Reminders: ${widget.task.reminders ?? "No reminders set"}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
