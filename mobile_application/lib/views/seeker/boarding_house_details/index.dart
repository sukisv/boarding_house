import 'package:flutter/material.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/viewmodels/owner/boarding_house_details/index.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/components/custom_button.dart';
import 'package:mobile_application/components/boarding_house_details_card.dart';
import 'package:mobile_application/components/image_carousel.dart';

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
      appBar: AppBar(title: Text('Boarding House Details')),
      body: FutureBuilder<BoardingHouse>(
        future: viewModel.fetchBoardingHouseDetails(boardingHouseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: [1m${snapshot.error}[22m'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No details available.'));
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
                        // TODO: Implementasi booking
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking feature coming soon!'),
                          ),
                        );
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
