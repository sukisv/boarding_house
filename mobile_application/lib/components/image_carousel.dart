import 'package:flutter/material.dart';
import 'package:mobile_application/models/boarding_house.dart';
import 'package:mobile_application/viewmodels/owner/boarding_house_details/index.dart';

class ImageCarousel extends StatefulWidget {
  final List<BoardingHouseImage> images;
  final BoardingHouseDetailsViewModel viewModel;
  const ImageCarousel({
    required this.images,
    required this.viewModel,
    super.key,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final imgUrl = widget.viewModel.getFullImageUrl(
                widget.images[index].imageUrl,
              );
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  imgUrl,
                  height: 200,
                  width: 320,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == i ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
