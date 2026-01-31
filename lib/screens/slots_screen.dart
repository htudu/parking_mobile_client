import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'reservation_screen.dart';
import 'my_reservations_screen.dart';
import 'settings_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({Key? key}) : super(key: key);

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  late Future<List<dynamic>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() {
    final api = Provider.of<ApiService>(context, listen: false);
    _slotsFuture = api.getAvailableSlots();
  }

  Future<void> _checkoutReservation(int reservationId) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.checkoutReservation(reservationId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully checked out!')),
        );
        setState(_loadSlots);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Slots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'My Reservations',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final api = Provider.of<ApiService>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout(api);
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_loadSlots);
        },
        child: FutureBuilder<List<dynamic>>(
          future: _slotsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(_loadSlots),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final slots = snapshot.data ?? [];
            if (slots.isEmpty) {
              return const Center(
                child: Text('No available slots'),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                final slot = slots[index];
                return SlotCard(
                  slot: slot,
                  onReserve: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReservationScreen(slotId: slot['id']),
                      ),
                    );
                    // Refresh slots if a reservation was made
                    if (result == true) {
                      setState(_loadSlots);
                    }
                  },
                  onCheckout: () async {
                    if (slot['reservation_id'] != null) {
                      await _checkoutReservation(slot['reservation_id']);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(_loadSlots),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class SlotCard extends StatelessWidget {
  final Map<String, dynamic> slot;
  final VoidCallback onReserve;
  final VoidCallback onCheckout;

  const SlotCard({
    Key? key,
    required this.slot,
    required this.onReserve,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot['is_available'] ?? false;
    final userHasReservation = slot['user_reservation'] ?? false;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isAvailable ? onReserve : (userHasReservation ? onCheckout : null),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.local_parking, size: 48),
              Text(
                slot['slot_number'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text(isAvailable ? 'Available' : 'Reserved'),
                backgroundColor: isAvailable ? Colors.green : Colors.red,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              if (isAvailable)
                ElevatedButton(
                  onPressed: onReserve,
                  child: const Text('Reserve'),
                )
              else if (userHasReservation)
                ElevatedButton.icon(
                  onPressed: onCheckout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                )
              else
                OutlinedButton(
                  onPressed: null,
                  child: const Text('Reserved'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
