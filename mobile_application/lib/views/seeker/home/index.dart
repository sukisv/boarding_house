import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/constants/api_constants.dart';
import 'package:mobile_application/models/booking.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/seeker/home/index.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Booking')),
      body: FutureBuilder<List<Booking>>(
        future: viewModel.fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan'));
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return Center(child: Text('Tidak ada booking'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final house = booking.boardingHouse;
              final facilities = house.facilities;
              final images = house.images;
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar di atas, full width
                      ImageCarouselBooking(images: images),
                      const SizedBox(height: 12),
                      // Info kos di bawah gambar
                      Text(
                        house.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        house.address,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      // Tambahkan nama pemilik dan nomor telepon
                      Text(
                        'Pemilik: ${house.owner.name}',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        'No. Telp: ${house.owner.phoneNumber}',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Harga: Rp ${house.pricePerMonth}/bulan',
                        style: TextStyle(fontSize: 13),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing:
                            6, // tambahkan runSpacing agar ada jarak vertikal antar fasilitas
                        children:
                            facilities
                                .map(
                                  (f) => Chip(
                                    label: Text(
                                      f.name,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.blue[50],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Booking: ${formatDate(booking.startDate)} s/d ${formatDate(booking.endDate)}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Status badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  booking.status == 'confirmed'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              booking.status[0].toUpperCase() +
                                  booking.status.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    booking.status == 'confirmed'
                                        ? Colors.green[800]
                                        : Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ImageCarouselBooking extends StatefulWidget {
  final List images;
  const ImageCarouselBooking({required this.images, super.key});

  @override
  State<ImageCarouselBooking> createState() => _ImageCarouselBookingState();
}

class _ImageCarouselBookingState extends State<ImageCarouselBooking> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  String getFullImageUrl(String url) {
    final cleaned = url.replaceAll('\\', '/');
    if (cleaned.startsWith('/')) {
      return apiBaseUrl + cleaned;
    } else {
      return '$apiBaseUrl/$cleaned';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        color: Colors.grey[300],
        child: Icon(Icons.image, size: 48),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final imgUrl = getFullImageUrl(widget.images[index].imageUrl);
              if (kDebugMode) {
                print(imgUrl);
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imgUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 48),
                      ),
                ),
              );
            },
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
