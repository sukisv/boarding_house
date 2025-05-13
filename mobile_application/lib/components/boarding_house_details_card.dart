import 'package:flutter/material.dart';
import 'package:mobile_application/models/boarding_house.dart';

class BoardingHouseDetailsCard extends StatelessWidget {
  final BoardingHouse house;

  const BoardingHouseDetailsCard({required this.house, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          house.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(house.description),
        SizedBox(height: 16),
        Text('Price: Rp ${house.pricePerMonth}/month'),
        SizedBox(height: 8),
        Text('Address: ${house.address}'),
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
    );
  }
}
