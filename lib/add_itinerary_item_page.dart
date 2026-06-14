// ignore_for_file: prefer_final_fields

import 'dart:convert'; // Encoders for packing custom trip metadata payloads
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/dataconnect_generated/generated.dart'; 
import 'l10n/app_localizations.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  bool _isSaving = false;
  
  // New States matching TripsPage internal configuration schemas
  String _selectedType = 'Leisure';
  DateTimeRange? _selectedRange;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Packs structured JSON metadata and commits it to Firebase tables
  Future<void> _handleCreateRoute() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your travel timeline dates.')),
      );
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No active user session found.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String routeName = _nameController.text.trim();

      // 👇 MATCHES TRIPSPAGE: Serialize metadata parameters into a single string container
      final String dynamicDescriptionPayload = jsonEncode({
        'type': _selectedType,
        'startDate': _selectedRange!.start.toIso8601String(),
        'endDate': _selectedRange!.end.toIso8601String(),
      });

      // Execute the mutation using your Data Connect connector instance hooks
      final operationResult = await ExampleConnector.instance.createRoute(
        userId: currentUser.uid, 
        name: routeName,
      )
      .description(dynamicDescriptionPayload) // 👈 Safe JSON insertion payload stream
      .execute();

      final String generatedRouteId = operationResult.data.route_insert.routeId;
      debugPrint('Successfully saved new route to Firebase with ID: $generatedRouteId');

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journey initialized successfully!')),
      );

      // 👉 POP & REFRESH: Pops back and returns true so TripsPage triggers a hot rebuild fetch cycle
      Navigator.pop(context, true);

    } catch (e) {
      debugPrint('Firebase Mutation Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save route: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final Map<String, String> categoryLabels = {
      'Leisure': l10n.category_leisure,
      'Education': l10n.category_education,
      'Culture': l10n.category_culture,
      'Adventure': l10n.category_adventure,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.trip_plan_new, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Trip Label Title Form Field Input
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.trip_name,
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Field 2: Date Picker Integration Elements Button Trigger
                    InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _selectedRange = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.teal),
                            const SizedBox(width: 12),
                            Text(
                              _selectedRange == null 
                                ? l10n.trip_select_dates 
                                : "${DateFormat('MMM d').format(_selectedRange!.start)} - ${DateFormat('MMM d').format(_selectedRange!.end)}",
                              style: TextStyle(color: _selectedRange == null ? Colors.grey[600] : Colors.black, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Field 3: Type Dropdown selection menu structure
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: l10n.trip_stops,
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      items: categoryLabels.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                    const SizedBox(height: 40),

                    // Action Execution Submission Button Block
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _handleCreateRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.trip_create_journey, 
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}