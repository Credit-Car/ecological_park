import 'package:flutter/material.dart';
// import '../models/trip.dart';
import '../models/places.dart';
import '../models/trip.dart';

class AddTripStopPage extends StatefulWidget {
  final Trip trip;
  final List<Places> availablePlaces;

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

  @override
  void initState() {
    super.initState();
    // Start the picker at the trip's start date for better UX
    _selectedDateTime = widget.trip.startDate;
  }

void _pickDateTime() async {
  // 1. Pick the Date
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: widget.trip.startDate,
    firstDate: widget.trip.startDate,
    lastDate: widget.trip.endDate,
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Colors.teal,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
      ),
      child: child!,
    ),
  );

  // Check if the user closed the page while the DatePicker was open
  if (!mounted) return; 

  if (pickedDate != null) {
    // 2. Pick the Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    // Check again before using context or calling setState
    if (!mounted) return;

    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }
}

  void _saveStop() {
    if (_formKey.currentState!.validate() && _selectedPlace != null && _selectedDateTime != null) {
      // Creating a new TripStop using the updated model structure
      final newStop = TripStop(
        place: _selectedPlace!,
        scheduledTime: _selectedDateTime!,
        customNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Mutate the local trip object (will be reflected in ItineraryDetailsPage)
      widget.trip.stops.add(newStop);
      
      // Sort stops by time automatically so the timeline stays chronological
      widget.trip.stops.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a building and time.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Colors.teal;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Stop', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              const Text("Select Building", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 12),
              
              // Place Selection Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<Places>(
                  decoration: const InputDecoration(border: InputBorder.none),
                  hint: const Text("Where are we going?"),
                  initialValue: _selectedPlace,
                  icon: const Icon(Icons.location_on_rounded, color: primaryTeal),
                  items: widget.availablePlaces.map((place) {
                    return DropdownMenuItem(
                      value: place,
                      child: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedPlace = val),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text("Arrival Time", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 12),

              // Date/Time Selection Tile
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryTeal.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded, color: primaryTeal),
                      const SizedBox(width: 16),
                      Text(
                        _selectedDateTime == null 
                          ? "Set Arrival Time" 
                          : "${_selectedDateTime!.day}/${_selectedDateTime!.month} @ ${TimeOfDay.fromDateTime(_selectedDateTime!).format(context)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryTeal),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 18, color: primaryTeal),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text("Task or Notes", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "What are you doing here? (Optional)",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _saveStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text("Save to Itinerary", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}