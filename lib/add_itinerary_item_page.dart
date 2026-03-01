import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/places.dart';

class AddTripStopPage extends StatefulWidget {
  final Trip trip;
  final List<Places> availablePlaces; // Pass your list of places here

  const AddTripStopPage({
    super.key, 
    required this.trip, 
    required this.availablePlaces
  });

  @override
  State<AddTripStopPage> createState() => _AddTripStopPageState();
}

class _AddTripStopPageState extends State<AddTripStopPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  Places? _selectedPlace;
  DateTime? _selectedDateTime;

  // Date/Time Picker
  void _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveStop() {
    if (_formKey.currentState!.validate() && _selectedPlace != null && _selectedDateTime != null) {
      final newStop = TripStop(
        place: _selectedPlace!,
        scheduledTime: _selectedDateTime!,
        customNotes: _notesController.text.trim(),
      );

      widget.trip.stops.add(newStop);
      
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a place and a time.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Stop', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Where are you going?", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              
              // Place Picker Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: DropdownButtonFormField<Places>(
                  decoration: const InputDecoration(border: InputBorder.none),
                  hint: const Text("Select a Place"),
                  value: _selectedPlace,
                  items: widget.availablePlaces.map((place) {
                    return DropdownMenuItem(
                      value: place,
                      child: Text(place.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedPlace = val),
                ),
              ),
              
              const SizedBox(height: 30),
              
              const Text("When?", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selectedDateTime == null ? Colors.transparent : const Color.fromARGB(255, 92, 184, 174)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: const Color.fromARGB(255, 92, 184, 174)),
                      const SizedBox(width: 16),
                      Text(
                        _selectedDateTime == null 
                          ? "Pick Date & Time" 
                          : "${_selectedDateTime!.day}/${_selectedDateTime!.month} @ ${TimeOfDay.fromDateTime(_selectedDateTime!).format(context)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text("Additional Notes", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "E.g. Don't forget the booking reference...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text("Add to Route", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}