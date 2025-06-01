import 'package:flutter/material.dart';
import '../../../components/search_form.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/models/boarding_house.dart';
import '../../../viewmodels/seeker/search/index.dart';
import 'package:mobile_application/views/seeker/boarding_house_details/index.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController searchController = TextEditingController();
  String selectedGender = 'mixed';
  final Map<String, String> genderOptions = {
    'male': 'Pria',
    'female': 'Wanita',
    'mixed': 'Campuran',
  };
  bool _loadingLocation = false;

  Future<void> _getCurrentCityAndSearch(SearchViewModel viewModel) async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _loadingLocation = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Izin lokasi ditolak')));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=10&addressdetails=1';
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'anak-kos-app'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city =
            data['address']?['city'] ??
            data['address']?['town'] ??
            data['address']?['village'] ??
            data['address']?['county'] ??
            '';
        if (city.isNotEmpty) {
          setState(() {
            searchController.text = city;
            _loadingLocation = false;
          });
          viewModel.applySearch(city, selectedGender);
        } else {
          setState(() => _loadingLocation = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mendapatkan nama kota')),
          );
        }
      } else {
        setState(() => _loadingLocation = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi')));
      }
    } catch (e) {
      setState(() => _loadingLocation = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi')));
    }
  }

  void _showFilterModal(BuildContext context, SearchViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        String tempGender = selectedGender;
        TextEditingController tempController = TextEditingController(
          text: searchController.text,
        );
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchForm(
                searchController: tempController,
                selectedGender: tempGender,
                genderOptions: genderOptions,
                onGenderChanged: (value) {
                  if (value != null) {
                    setState(() {
                      tempGender = value;
                    });
                  }
                },
                onApply: () {
                  setState(() {
                    searchController.text = tempController.text;
                    selectedGender = tempGender;
                  });
                  viewModel.applySearch(searchController.text, selectedGender);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pencarian'),
              actions: [
                IconButton(
                  icon:
                      _loadingLocation
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.location_on, color: Colors.blue),
                  tooltip: 'Lokasi Sekarang',
                  onPressed:
                      _loadingLocation
                          ? null
                          : () => _getCurrentCityAndSearch(viewModel),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.black,
                      ),
                      tooltip: 'Filter & Cari',
                      onPressed: () => _showFilterModal(context, viewModel),
                    ),
                    if (searchController.text.isNotEmpty ||
                        selectedGender != 'mixed')
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent &&
                            !viewModel.isLoading) {
                          viewModel.fetchNextPage();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount:
                            viewModel.boardingHouses.length +
                            (viewModel.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == viewModel.boardingHouses.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final house = viewModel.boardingHouses[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          SeekerBoardingHouseDetailsView(
                                            boardingHouseId: house.id,
                                          ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              margin: const EdgeInsets.all(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      house.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(house.description),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pemilik: ${house.owner.name}',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    Text(
                                      'No. Telp: ${house.owner.phoneNumber}',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
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
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Rp ${house.pricePerMonth}/bulan',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children:
                                          house.facilities.map((facility) {
                                            return Chip(
                                              label: Text(
                                                facility.name,
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              backgroundColor: Colors.blue[50],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
