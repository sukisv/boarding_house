import 'package:flutter/material.dart';
import 'package:mobile_application/components/form_boarding_house_modal.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/viewmodels/owner/boarding_house_details/index.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/components/custom_button.dart';
import 'package:mobile_application/components/boarding_house_details_card.dart';
import 'package:mobile_application/components/image_carousel.dart';
import 'package:mobile_application/components/button_group.dart';
import 'package:mobile_application/views/owner/boarding_house_update_image/index.dart';

class BoardingHouseDetailsView extends StatelessWidget {
  final String boardingHouseId;

  const BoardingHouseDetailsView({required this.boardingHouseId, super.key});

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
            return Center(
              child: Text('Terjadi kesalahan: \\${snapshot.error}'),
            );
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
                ButtonGroupComponent(
                  children: [
                    CustomButton(
                      label: 'Hapus',
                      onPressed: () {
                        viewModel.deleteBoardingHouse(house.id);
                        Navigator.pop(context);
                      },
                    ),
                    CustomButton(
                      label: 'Edit',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => FormBoardingHouseModal(
                                  nameController: TextEditingController(
                                    text: house.name,
                                  ),
                                  descriptionController: TextEditingController(
                                    text: house.description,
                                  ),
                                  addressController: TextEditingController(
                                    text: house.address,
                                  ),
                                  cityController: TextEditingController(
                                    text: house.city,
                                  ),
                                  priceController: TextEditingController(
                                    text: house.pricePerMonth.toString(),
                                  ),
                                  roomsController: TextEditingController(
                                    text: house.roomAvailable.toString(),
                                  ),
                                  genderAllowed: house.genderAllowed,
                                  onSubmit: () {
                                    Navigator.pop(context);
                                  },
                                  existingHouse: house,
                                  selectedFacilities:
                                      house.facilities
                                          .map((f) => f.id)
                                          .toList(),
                                ),
                          ),
                        );
                      },
                    ),
                    CustomButton(
                      label: 'Perbarui Gambar',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BoardingHouseUpdateImageView(
                                  boardingHouseId: house.id,
                                ),
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
