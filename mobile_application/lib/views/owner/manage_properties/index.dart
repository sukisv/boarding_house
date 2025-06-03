import 'package:flutter/material.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/viewmodels/owner/manage_property/index.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:mobile_application/components/form_boarding_house_modal.dart';

class ManagePropertiesView extends StatefulWidget {
  const ManagePropertiesView({super.key});

  @override
  State<ManagePropertiesView> createState() => _ManagePropertiesViewState();
}

class _ManagePropertiesViewState extends State<ManagePropertiesView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  String? genderAllowed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ManagePropertyViewModel>();
      viewModel.fetchBoardingHouses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ManagePropertyViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Kelola Properti')),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              !viewModel.isLoading) {
            viewModel.fetchNextPage();
          }
          return false;
        },
        child: ListView.builder(
          itemCount:
              viewModel.boardingHouses.length + (viewModel.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == viewModel.boardingHouses.length) {
              return Center(child: CircularProgressIndicator());
            }

            final house = viewModel.boardingHouses[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              margin: EdgeInsets.all(8),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    Routes.boardingHouseDetails,
                    arguments: house.id,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        house.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(house.description),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              BoardingHouse.getGenderLabelStatic(
                                house.genderAllowed,
                              ),
                              style: TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Rp ${house.pricePerMonth}/bulan'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children:
                            house.facilities.map((facility) {
                              return Chip(
                                label: Text(facility.name),
                                backgroundColor: Colors.blue[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateModal(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: FormBoardingHouseModal(
                    nameController: nameController,
                    descriptionController: descriptionController,
                    addressController: addressController,
                    cityController: cityController,
                    priceController: priceController,
                    roomsController: roomsController,
                    genderAllowed: genderAllowed,
                    onSubmit: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
