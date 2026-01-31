import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'qr_scanner_screen.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({Key? key}) : super(key: key);

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  late Future<List<dynamic>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    final api = Provider.of<ApiService>(context, listen: false);
    _reservationsFuture = api.getMyReservations();
  }

  void _handleCheckout(int reservationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout Reservation'),
        content: const Text('Are you sure you want to checkout from this slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final api = Provider.of<ApiService>(context, listen: false);
                await api.checkoutReservation(reservationId);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully checked out')),
                );
                
                setState(_loadReservations);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Yes, Checkout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Scan QR to Checkout',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_loadReservations);
        },
        child: FutureBuilder<List<dynamic>>(
          future: _reservationsFuture,
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
                      onPressed: () => setState(_loadReservations),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final reservations = snapshot.data ?? [];
            if (reservations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text('No reservations yet'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Browse Slots'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return ReservationCard(
                  reservation: reservation,
                  onCheckout: () => _handleCheckout(reservation['id']),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final VoidCallback onCheckout;

  const ReservationCard({
    Key? key,
    required this.reservation,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Slot: ${reservation['slot_number'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: const Text('Active'),
                  backgroundColor: Colors.green[300],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reserved: ${_formatDate(reservation['reserved_at'])}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('QR Code'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (reservation['qr_image'] != null)
                              Image.network(
                                reservation['qr_image'],
                                width: 200,
                                height: 200,
                              )
                            else
                              Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text('No QR Code'),
                                ),
                              ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('View QR'),
                ),
                ElevatedButton.icon(
                  onPressed: onCheckout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      // Assuming ISO format from API
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date.toString();
    }
  }
}
