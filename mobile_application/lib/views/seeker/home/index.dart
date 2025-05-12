import 'package:flutter/material.dart';
import '../../../viewmodels/seeker/home/index.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('Boarding Houses')),
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
                            house.getGenderLabel(house.genderAllowed),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
