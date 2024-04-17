import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class TaskDetails extends StatefulWidget {
  final Task task;

  const TaskDetails({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}


class _TaskDetailsState extends State<TaskDetails> {
  // options for status
  List<String> statusOptions = ['To do', 'Started', 'In progress', 'Completed', 'Overdue'];
  List<String> importanceOptions = [for (int i = 1; i < 6; i++) i.toString()];
  late TextEditingController _nameController;
  bool _isEditingName = false;
  String? _currentStatus;
  String? _currentImportance;

  // initialize data from database
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

  Future<void> _pickDate(bool isDueDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.task.dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      _pickTime(pickedDate, isDueDate);
    }
  }

  Future<void> _pickTime(DateTime pickedDate, bool isDueDate) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.task.dueDate ?? DateTime.now()),
    );
    if (pickedTime != null) {
      final DateTime newDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setState(() {
        // set due date
        if (isDueDate) {
          widget.task.dueDate = newDateTime;
          print("Due date is set to $newDateTime");
        } 
        // set reminder
        else {
          widget.task.reminders = newDateTime;
          print("Reminder is set to $newDateTime");
        }
      });
    }
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
            // Task name field 
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

            // Due date field
            InkWell(
              onTap:() {
                _pickDate(true);
              },
              child: Text(
                'Due Date: ${widget.task.dueDate != null ? DateFormat('yyyy-MM-dd – HH:mm').format(widget.task.dueDate!) : "N/A"}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),

            // Status field
            DropdownButton<String>(
              value: _currentStatus,
              hint: const Text("Status"),
              icon: const Icon(Icons.arrow_downward),
              onChanged: (String? value) {
                setState(() {
                  _currentStatus = value;
                  widget.task.status = value;
                  print("Status is set to $value");
                });
              },
              items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),

            // Importance field
            DropdownButton<String>(
              value: _currentImportance,
              hint: Text("Importance"),
              icon: Icon(Icons.arrow_downward),
              onChanged: (String? value) {
                setState(() {
                  _currentImportance = value;
                  widget.task.importance = value; 
                  print("Importance is set to $value");
                });
              },
              items: importanceOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            SizedBox(height: 10),

            // Reminders field
            InkWell(
              onTap:() {
                _pickDate(false);
              },
              child: Text(
                'Reminders: ${widget.task.reminders != null ? DateFormat('yyyy-MM-dd – HH:mm').format(widget.task.reminders!) : "N/A"}',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
