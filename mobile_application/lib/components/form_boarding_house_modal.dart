import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_application/components/custom_input.dart';
import 'package:mobile_application/components/custom_button.dart';
import 'package:mobile_application/components/custom_dropdown.dart';
import 'package:mobile_application/components/custom_checkbox.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/services/api_service.dart';

class FormBoardingHouseModal extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController priceController;
  final TextEditingController roomsController;
  final String? genderAllowed;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onSubmit;

  const FormBoardingHouseModal({
    required this.nameController,
    required this.descriptionController,
    required this.addressController,
    required this.cityController,
    required this.priceController,
    required this.roomsController,
    required this.genderAllowed,
    required this.onGenderChanged,
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  @override
  _FormBoardingHouseModalState createState() => _FormBoardingHouseModalState();
}

class _FormBoardingHouseModalState extends State<FormBoardingHouseModal> {
  List<Facility> facilities = [];
  List<String> selectedFacilities = [];
  bool isLoading = true;
  BoardingHouse? existingHouse;

  @override
  void initState() {
    super.initState();
    fetchFacilities();
  }

  Future<void> fetchFacilities() async {
    if (facilities.isNotEmpty) return;

    isLoading = true;
    try {
      final response = await ApiService().get('/api/facilities');
      final decodedResponse = jsonDecode(response.body);
      final data = decodedResponse['data'] as List<dynamic>;
      facilities =
          data.map((facilityJson) => Facility.fromJson(facilityJson)).toList();
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching facilities: $e');
      }
    } finally {
      isLoading = false;
    }
  }

  Future<void> createBoardingHouse(BoardingHouse boardingHouse) async {
    isLoading = true;

    try {
      final data = {
        'name': boardingHouse.name,
        'description': boardingHouse.description,
        'address': boardingHouse.address,
        'city': boardingHouse.city,
        'price_per_month': boardingHouse.pricePerMonth,
        'room_available': boardingHouse.roomAvailable,
        'gender_allowed': boardingHouse.genderAllowed,
        'facilities': boardingHouse.facilities.map((f) => f.id).toList(),
      };

      final response = await ApiService().post(
        '/api/boarding-houses',
        body: data,
      );
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Boarding house created successfully.');
        }
      } else {
        throw Exception('Failed to create boarding house.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating boarding house: $e');
      }
    } finally {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nameController.text.isEmpty &&
        widget.descriptionController.text.isEmpty) {
      widget.nameController.text = existingHouse?.name ?? '';
      widget.descriptionController.text = existingHouse?.description ?? '';
      widget.addressController.text = existingHouse?.address ?? '';
      widget.cityController.text = existingHouse?.city ?? '';
      widget.priceController.text =
          existingHouse?.pricePerMonth.toString() ?? '';
      widget.roomsController.text =
          existingHouse?.roomAvailable.toString() ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          existingHouse != null
              ? 'Update Boarding House'
              : 'Add Boarding House',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              CustomInput(controller: widget.nameController, hintText: 'Name'),
              CustomInput(
                controller: widget.descriptionController,
                hintText: 'Description',
              ),
              CustomInput(
                controller: widget.addressController,
                hintText: 'Address',
              ),
              CustomInput(controller: widget.cityController, hintText: 'City'),
              CustomInput(
                controller: widget.priceController,
                hintText: 'Price per Month',
                keyboardType: TextInputType.number,
              ),
              CustomInput(
                controller: widget.roomsController,
                hintText: 'Rooms Available',
                keyboardType: TextInputType.number,
              ),
              CustomDropdown(
                value: widget.genderAllowed ?? 'mixed',
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Pria', style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Wanita', style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: 'mixed',
                    child: Text('Campur', style: TextStyle(fontSize: 12)),
                  ),
                ],
                onChanged: widget.onGenderChanged,
              ),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    facilities.map((facility) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 24,
                        child: CustomCheckbox(
                          label: facility.name,
                          value: selectedFacilities.contains(facility.id),
                          onChanged: (isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                selectedFacilities.add(facility.id);
                              } else {
                                selectedFacilities.remove(facility.id);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
              CustomButton(
                label: existingHouse != null ? 'Update' : 'Submit',
                onPressed: () async {
                  final data = {
                    'name': widget.nameController.text,
                    'description': widget.descriptionController.text,
                    'address': widget.addressController.text,
                    'city': widget.cityController.text,
                    'price_per_month': int.parse(widget.priceController.text),
                    'room_available': int.parse(widget.roomsController.text),
                    'gender_allowed': widget.genderAllowed ?? 'mixed',
                    'facility_ids': selectedFacilities,
                  };

                  if (existingHouse != null) {
                    await ApiService().put(
                      '/api/boarding-houses/${existingHouse!.id}',
                      body: data,
                    );
                  } else {
                    await ApiService().post('/api/boarding-houses', body: data);
                  }
                  widget.onSubmit();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
