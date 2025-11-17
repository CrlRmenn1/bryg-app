import 'package:flutter/material.dart';
import 'admin_event_form.dart'; // <-- Your form screen

class AdminEventScreen extends StatelessWidget {
  const AdminEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Events",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              EventCard(
                title: "Community Clean-Up Drive",
                date: "March 12 • 8:00 AM",
                location: "Barangay Hall → Riverside",
                imagePath: "assets/event_placeholder.png",
              ),
              SizedBox(height: 16),

              EventCard(
                title: "Health & Wellness Seminar",
                date: "March 5 • 2:00 PM",
                location: "Barangay Multi-Purpose Gym",
                imagePath: "assets/event_placeholder.png",
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B2CBF),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminEventForm()),
          );
        },
        child: const Icon(
          Icons.event_available_rounded, // Event icon
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}

//
// ---------------------------------------------------------
// EVENT CARD WIDGET
// ---------------------------------------------------------
//
class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imagePath;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Image.asset(
              imagePath,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Date
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
