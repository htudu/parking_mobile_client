import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      autoStart: true,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String? code) async {
    if (code == null || _hasScanned) return;

    setState(() {
      _hasScanned = true;
    });

    try {
      // Extract reservation ID from QR code (assumes format like "reservation:123")
      final reservationId = _extractReservationId(code);

      if (reservationId == null) {
        _showError('Invalid QR Code format');
        setState(() => _hasScanned = false);
        return;
      }

      // Show confirmation dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Checkout Confirmation'),
            content: Text('Checkout from reservation #$reservationId?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _hasScanned = false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    final api = Provider.of<ApiService>(context, listen: false);
                    await api.checkoutReservation(reservationId);

                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Success! ✅'),
                          content: const Text('You have successfully checked out'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context, true); // Return to reservations with true
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    _showError('Checkout failed: $e');
                    setState(() => _hasScanned = false);
                  }
                },
                child: const Text('Yes, Checkout',
                    style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
      setState(() => _hasScanned = false);
    }
  }

  int? _extractReservationId(String qrData) {
    try {
      // Try different formats:
      // Format 1: "reservation:123"
      if (qrData.contains(':')) {
        final parts = qrData.split(':');
        return int.tryParse(parts.last);
      }
      // Format 2: Just a number
      return int.tryParse(qrData);
    } catch (e) {
      return null;
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (!_hasScanned) {
                  _processQRCode(barcode.rawValue);
                }
              }
            },
          ),
          // Overlay with scanning frame
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 3,
                        color: Colors.green,
                      ),
                      Container(
                        width: double.infinity,
                        height: 3,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Instructions at bottom
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Point camera at QR code to checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // Torch toggle button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => controller.toggleTorch(),
              tooltip: 'Toggle Torch',
              child: ValueListenableBuilder(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
