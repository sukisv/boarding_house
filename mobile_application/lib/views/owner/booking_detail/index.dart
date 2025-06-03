import 'package:flutter/material.dart';
import 'package:mobile_application/models/booking.dart';
import 'package:mobile_application/viewmodels/owner/booking_detail/index.dart';
import 'package:provider/provider.dart';

class BookingDetailView extends StatelessWidget {
  final String bookingId;
  const BookingDetailView({required this.bookingId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingDetailViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Booking')),
        body: Consumer<BookingDetailViewModel>(
          builder: (context, viewModel, _) {
            return FutureBuilder<Booking?>(
              future: viewModel.fetchBookingDetail(bookingId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No detail available'));
                }
                final booking = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengguna: ${booking.user.name}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text('Kos: ${booking.boardingHouse.name}'),
                      const SizedBox(height: 8),
                      Text('Status: ${booking.status}'),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal Mulai: ${booking.startDate.isNotEmpty ? booking.startDate.substring(0, 10) : '-'}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal Selesai: ${booking.endDate.isNotEmpty ? booking.endDate.substring(0, 10) : '-'}',
                      ),
                      const SizedBox(height: 16),
                      if (booking.status == 'pending')
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final success = await viewModel
                                    .updateBookingStatus(
                                      booking.id,
                                      'confirmed',
                                    );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Booking dikonfirmasi'),
                                    ),
                                  );
                                  // Refresh detail
                                  (context as Element).markNeedsBuild();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal konfirmasi'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Konfirmasi'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                final success = await viewModel
                                    .updateBookingStatus(
                                      booking.id,
                                      'cancelled',
                                    );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Booking ditolak'),
                                    ),
                                  );
                                  (context as Element).markNeedsBuild();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal menolak'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Tolak'),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
