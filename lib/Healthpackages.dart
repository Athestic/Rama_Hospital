import 'package:flutter/material.dart';
import 'package:global/colors.dart';

class HealthPackages extends StatelessWidget {
  final List<String> images = [
    'assets/specialities/card2.jpg',
    'assets/specialities/card3.jpg',
    'assets/specialities/card4.jpg',
    'assets/specialities/card5.jpg',
    'assets/specialities/card6.jpg',
    'assets/specialities/card7.jpg',
    'assets/specialities/card8.jpg',
    'assets/specialities/card9.jpg'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Packages',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns in the grid
            crossAxisSpacing: 10.0, // Horizontal space between items
            mainAxisSpacing: 10.0, // Vertical space between items
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0), // Rounded corners
                border: Border.all(color: Colors.teal, width: 2.0), // Border
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Shadow position
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.0),
                child: Image.asset(
                  images[index],
                  fit: BoxFit.cover, // Fit the image to cover the container
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
