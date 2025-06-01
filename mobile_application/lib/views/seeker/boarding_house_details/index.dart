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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Fitur booking segera hadir!'),
                          ),
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
