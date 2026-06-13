import 'package:flutter/material.dart';
import '../models/places.dart';
import '../models/trip.dart';
import 'l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

    if (!mounted) return; 

    if (pickedDate != null) {
      // 2. Pick the Time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 12, minute: 0),
      );

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
      final newStop = TripStop(
        place: _selectedPlace!,
        scheduledTime: _selectedDateTime!,
        customNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      widget.trip.stops.add(newStop);
      widget.trip.stops.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      
      Navigator.pop(context, true);
    } else {
      // Fallback if selections are incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location and time.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Colors.teal;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.btn_add, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
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
              // Localized: "景點" / "Scenic Spot" (or use filter_scenic_spot dynamically)
              Text(l10n.filter_scenic_spot, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
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
                  // Localized: "Aa" or custom placeholder text can be added, otherwise localized target fallback:
                  hint: Text(l10n.chatbot_placeholder.substring(0, 7) + "..."), 
                  value: _selectedPlace,
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
              
              // Localized: "停靠站" / "Stops"
              Text(l10n.trip_stops, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
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
                          ? l10n.trip_select_dates 
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

              // Localized: "關於園區" / "About Park" (Acts as dynamic overview header helper)
              Text(l10n.nav_about, 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.chatbot_placeholder, // Reuses "Ask about destinations..." input block hint
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
                  // Localized: "建立旅程" / "Create Journey"
                  child: Text(l10n.trip_create_journey, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}