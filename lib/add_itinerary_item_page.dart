// lib/pages/add_itinerary_item_page.dart
import 'package:flutter/material.dart';
import '../models/route.dart';
import '../models/itinerary_item.dart';

class AddItineraryItemPage extends StatefulWidget {
  final Route trip;
  const AddItineraryItemPage({super.key, required this.trip});

  @override
  State<AddItineraryItemPage> createState() => _AddItineraryItemPageState();
}

class _AddItineraryItemPageState extends State<AddItineraryItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _urlController = TextEditingController();

  ItineraryItemType _selectedType = ItineraryItemType.activity;
  DateTime? _selectedDateTime;

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _saveItem() {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      final newItem = ItineraryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        title: _titleController.text.trim(),
        time: _selectedDateTime!,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes:
            _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        actionUrl:
            _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      );

      // Normally you’d save this to a database or pass it back.
      // For now, we’ll just print it.
      print('✅ New Itinerary Item Added: ${newItem.title}');

      Navigator.pop(context, newItem);
    } else if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Itinerary Item'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Type Dropdown
              DropdownButtonFormField<ItineraryItemType>(
                decoration: const InputDecoration(
                  labelText: 'Item Type',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedType,
                items: ItineraryItemType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 20),

              // Date & Time
              InkWell(
                onTap: _pickDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date & Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDateTime == null
                        ? 'Select date and time'
                        : '${_selectedDateTime!.toLocal()}'.split('.')[0],
                    style: TextStyle(
                      color: _selectedDateTime == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Action URL
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Action URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveItem,
                  icon: const Icon(Icons.check),
                  label: const Text('Save Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
