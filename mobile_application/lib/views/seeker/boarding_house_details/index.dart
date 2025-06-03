import 'package:flutter/material.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/viewmodels/owner/boarding_house_details/index.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/components/custom_button.dart';
import 'package:mobile_application/components/boarding_house_details_card.dart';
import 'package:mobile_application/components/image_carousel.dart';
import 'package:url_launcher/url_launcher.dart';

class SeekerBoardingHouseDetailsView extends StatelessWidget {
  final String boardingHouseId;

  const SeekerBoardingHouseDetailsView({
    required this.boardingHouseId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BoardingHouseDetailsViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Detail Kos')),
      body: FutureBuilder<BoardingHouse>(
        future: viewModel.fetchBoardingHouseDetails(boardingHouseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Detail tidak tersedia.'));
          }

          final house = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (house.images.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: ImageCarousel(
                      images: house.images,
                      viewModel: viewModel,
                    ),
                  ),
                ],
                BoardingHouseDetailsCard(house: house),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      label: 'Booking',
                      onPressed: () async {
                        DateTime? startDate;
                        DateTime? endDate;
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                                left: 16,
                                right: 16,
                                top: 24,
                              ),
                              child: StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Booking Kos',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tanggal Mulai',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(
                                              Duration(days: 365),
                                            ),
                                          );
                                          if (picked != null) {
                                            setModalState(
                                              () => startDate = picked,
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          height: 32,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            startDate != null
                                                ? startDate!
                                                    .toIso8601String()
                                                    .substring(0, 10)
                                                : 'Pilih tanggal mulai',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tanggal Selesai',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate:
                                                startDate ?? DateTime.now(),
                                            firstDate:
                                                startDate ?? DateTime.now(),
                                            lastDate: DateTime.now().add(
                                              Duration(days: 365),
                                            ),
                                          );
                                          if (picked != null) {
                                            setModalState(
                                              () => endDate = picked,
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          height: 32,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            endDate != null
                                                ? endDate!
                                                    .toIso8601String()
                                                    .substring(0, 10)
                                                : 'Pilih tanggal selesai',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      CustomButton(
                                        label: 'Konfirmasi Booking',
                                        onPressed: () async {
                                          if (startDate == null ||
                                              endDate == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Pilih tanggal mulai dan selesai!',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          Navigator.pop(context);
                                          final success = await viewModel
                                              .bookingBoardingHouse(
                                                boardingHouseId: house.id,
                                                startDate: startDate!,
                                                endDate: endDate!,
                                              );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                success
                                                    ? 'Booking berhasil!'
                                                    : 'Booking gagal!',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(width: 12),
                    CustomButton(
                      label: 'Chat',
                      onPressed: () async {
                        String phone = house.owner.phoneNumber;
                        // Ubah 08xxx menjadi 628xxx jika perlu
                        if (phone.startsWith('0')) {
                          phone = '62${phone.substring(1)}';
                        }
                        final url = 'https://wa.me/$phone';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tidak dapat membuka WhatsApp.'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
