import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_application/viewmodels/owner/boarding_house_update_image/index.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:provider/provider.dart';

class BoardingHouseUpdateImageView extends StatefulWidget {
  final String boardingHouseId;
  const BoardingHouseUpdateImageView({
    required this.boardingHouseId,
    super.key,
  });

  @override
  State<BoardingHouseUpdateImageView> createState() =>
      _BoardingHouseUpdateImageViewState();
}

class _BoardingHouseUpdateImageViewState
    extends State<BoardingHouseUpdateImageView> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  List<BoardingHouseImage> _currentImages = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    final viewModel = Provider.of<BoardingHouseUpdateImageViewModel>(
      context,
      listen: false,
    );
    try {
      final house = await viewModel.fetchBoardingHouseDetails(
        widget.boardingHouseId,
      );
      setState(() {
        _currentImages = house.images;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<BoardingHouseUpdateImageViewModel>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(title: Text('Update Images')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                final picked = await _picker.pickMultiImage();
                if (picked.isNotEmpty) {
                  setState(() {
                    _selectedImages = picked;
                  });
                }
              },
              child: Text('Pilih Gambar'),
            ),
            if (_selectedImages.isNotEmpty)
              Wrap(
                spacing: 10,
                children:
                    _selectedImages
                        .map(
                          (img) => ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(img.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        .toList(),
              ),
            if (_selectedImages.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await viewModel.uploadImages(
                    widget.boardingHouseId,
                    _selectedImages.map((xfile) => File(xfile.path)).toList(),
                  );
                  setState(() {
                    _selectedImages = [];
                  });
                  await _loadImages();
                },
                child: Text('Upload'),
              ),
            const SizedBox(height: 16),
            Text(
              'Gambar Saat Ini:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _currentImages.isEmpty
                      ? Center(child: Text('Belum ada gambar'))
                      : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentImages.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final img = _currentImages[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  viewModel.getFullImageUrl(img.imageUrl),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    setState(() => _isLoading = true);
                                    await viewModel.deleteImage(
                                      widget.boardingHouseId,
                                      img.id,
                                    );
                                    await _loadImages();
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
