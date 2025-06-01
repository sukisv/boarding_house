import 'package:flutter/material.dart';
import 'package:mobile_application/models/booking.dart';
import 'package:mobile_application/viewmodels/owner/notifications/index.dart';
import 'package:mobile_application/views/owner/booking_detail/index.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['pending', 'confirmed', 'cancelled'];
  final List<String> _tabTitles = ['Pending', 'Dikonfirmasi', 'Dibatalkan'];
  final Map<String, List<Booking>> _bookingsMap = {};
  final Map<String, int> _pageMap = {};
  final Map<String, int> _totalPagesMap = {};
  final Map<String, bool> _loadingMap = {};
  final Map<String, bool> _hasMoreMap = {};
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    for (var status in _statuses) {
      _bookingsMap[status] = [];
      _pageMap[status] = 1;
      _totalPagesMap[status] = 1;
      _loadingMap[status] = false;
      _hasMoreMap[status] = true;
      _scrollControllers[status] = ScrollController();
      _scrollControllers[status]!.addListener(() => _onScroll(status));
      _fetchBookings(status, 1);
    }
  }

  void _onScroll(String status) {
    final controller = _scrollControllers[status]!;
    if (controller.position.pixels >=
            controller.position.maxScrollExtent - 100 &&
        !_loadingMap[status]! &&
        _hasMoreMap[status]!) {
      _fetchBookings(status, _pageMap[status]! + 1);
    }
  }

  Future<void> _fetchBookings(String status, int page) async {
    setState(() {
      _loadingMap[status] = true;
    });
    final result = await OwnerNotificationViewModel().fetchBookingsPaged(
      status,
      page,
    );
    final List<Booking> newBookings = result['bookings'] ?? [];
    final meta = result['meta'] ?? {};
    setState(() {
      if (page == 1) {
        _bookingsMap[status] = newBookings;
      } else {
        _bookingsMap[status]!.addAll(newBookings);
      }
      _pageMap[status] = page;
      _totalPagesMap[status] = meta['total_pages'] ?? 1;
      _hasMoreMap[status] =
          page < (_totalPagesMap[status] ?? 1) && newBookings.isNotEmpty;
      _loadingMap[status] = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Dikonfirmasi'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            _statuses.map((status) {
              final bookings = _bookingsMap[status] ?? [];
              final loading = _loadingMap[status] ?? false;
              final hasMore = _hasMoreMap[status] ?? false;
              final controller = _scrollControllers[status]!;
              if (loading && bookings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bookings.isEmpty) {
                return const Center(child: Text('Tidak ada booking'));
              }
              return ListView.builder(
                controller: controller,
                itemCount: bookings.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == bookings.length && hasMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final booking = bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(booking.user.name),
                      subtitle: Text(booking.boardingHouse.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    BookingDetailView(bookingId: booking.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }
}
