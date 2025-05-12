import 'package:flutter/material.dart';
import 'package:mobile_application/components/half_modal.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/viewmodels/owner/manage_property/index.dart';
import 'package:provider/provider.dart';

class ManagePropertiesView extends StatefulWidget {
  const ManagePropertiesView({super.key});

  @override
  State<ManagePropertiesView> createState() => _ManagePropertiesViewState();
}

class _ManagePropertiesViewState extends State<ManagePropertiesView> {
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
      appBar: AppBar(title: Text('Manage Properties')),
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
                          ),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Rp ${house.pricePerMonth}/month'),
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
                            );
                          }).toList(),
                    ),
                  ],
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
    final viewModel = context.read<ManagePropertyViewModel>();
    viewModel.fetchFacilities();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return HalfModal(
          title: 'Create Boarding House',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(decoration: InputDecoration(labelText: 'Name')),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(decoration: InputDecoration(labelText: 'Address')),
                TextField(decoration: InputDecoration(labelText: 'City')),
                TextField(
                  decoration: InputDecoration(labelText: 'Price per Month'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Rooms Available'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
                  ],
                  onChanged: (value) {},
                  decoration: InputDecoration(labelText: 'Gender Allowed'),
                ),
                ...viewModel.facilities.map(
                  (facility) => CheckboxListTile(
                    title: Text(facility.name),
                    value: false,
                    onChanged: (value) {},
                  ),
                ),
                ElevatedButton(onPressed: () {}, child: Text('Submit')),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditModal(BuildContext context, BoardingHouse house) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return HalfModal(
          title: 'Edit Boarding House',
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Form for editing boarding house goes here.'),
          ),
        );
      },
    );
  }
}
