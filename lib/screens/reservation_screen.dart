import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationScreen extends StatefulWidget {
  final int slotId;

  const ReservationScreen({Key? key, required this.slotId}) : super(key: key);

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  late Future<Map<String, dynamic>> _reservationFuture;

  @override
  void initState() {
    super.initState();
    _makeReservation();
  }

  void _makeReservation() {
    final api = Provider.of<ApiService>(context, listen: false);
    setState(() {
      _reservationFuture = api.reserveSlot(widget.slotId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reservation Details'),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
        future: _reservationFuture,
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final reservation = snapshot.data ?? {};
          print('=== Reservation Response ===');
          print('Keys: ${reservation.keys}');
          print('Full response: $reservation');
          
          // Try to get QR data from either field
          final qrImageData = reservation['qr_code_image'] ?? reservation['qr_code_data'];
          print('QR Image Data available: ${qrImageData != null}');
          
          Widget qrWidget;
          
          // Decode using helper method
          final imageBytes = ApiService.decodeQRImage(qrImageData);
          
          if (imageBytes != null && imageBytes.isNotEmpty) {
            print('Successfully decoded QR image: ${imageBytes.length} bytes');
            qrWidget = SizedBox(
              width: 200,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    print('Image widget error: $error\n$stackTrace');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Image Error',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            print('Failed to decode QR image');
            qrWidget = Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('QR Code Not Available'),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'Reservation Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Parking QR Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        qrWidget,
                        const SizedBox(height: 16),
                        Text(
                          'Slot: ${reservation['slot_number'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reserved: ${reservation['reserved_at'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true); // Return true to indicate reservation was made
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Back to Slots'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}
