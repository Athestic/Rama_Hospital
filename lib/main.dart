import 'package:flutter/material.dart';
import 'view_all_doctors.dart';
import 'package:bottom_navigation/Homepage.dart';
import 'dart:async';
import 'colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Medical Solution',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SliderSplashScreen(),
    );
  }
}

class SliderSplashScreen extends StatefulWidget {
  @override
  _SliderSplashScreenState createState() => _SliderSplashScreenState();
}

class _SliderSplashScreenState extends State<SliderSplashScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _splashSeen = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  List<Widget> _pages = [
    SplashPage(
      imagePath: 'assets/splash/heart_splash.png',
      title: 'RamaPulse',
      description: 'Rama Hospital',
      isFirstPage: true,
    ),
    SplashPage(
      imagePath: 'assets/splash/splash2.png',
      title: 'Advanced Patient Care',
      description: 'Comprehensive Treatment Solutions',
      isCustomTitle: true,
    ),
    SplashPage(
      imagePath: 'assets/splash/splash3.png',
      title: 'Expert Medical Team',
      description: 'Dedicated to Your Health',
      isCustomTitle: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_splashSeen) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _pages[index];
              },
            ),
            if (_currentPage != 0)
              Positioned(
                bottom: 20.0,
                left: 20.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(_pages.length - 1, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      height: 10.0,
                      width: (_currentPage - 1) == index ? 20.0 : 10.0,
                      decoration: BoxDecoration(
                        color: (_currentPage - 1) == index ? Colors.teal : Colors.green,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
        floatingActionButton: _currentPage >= 1 && _currentPage <= 3
            ? FloatingActionButton(
          onPressed: () {
            if (_currentPage < _pages.length - 1) {
              _pageController.nextPage(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeIn,
              );
            } else {
              setState(() {
                _splashSeen = true;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          },
          child: Icon(Icons.arrow_forward, color: Colors.white),
          backgroundColor: AppColors.primaryColor,
        )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? description;
  final bool isFirstPage;
  final bool isCustomTitle;

  SplashPage({
    required this.imagePath,
    required this.title,
    this.description,
    this.isFirstPage = false,
    this.isCustomTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(imagePath),
                    if (isFirstPage)
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: 'Rama',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Pulse',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isCustomTitle)
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: '',
                          children: title.split(' ').map((word) {
                            Color color = Colors.black;
                            if (word == 'Advanced' || word == 'Care' || word == 'Medical') {
                              color = Colors.black;
                            } else if (word == 'Patient' || word == 'Expert') {
                              color = AppColors.primaryColor;
                            }
                            return TextSpan(
                              text: word + ' ',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontFamily: 'Poppins',
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20.0), // Space between title and description
              if (!isFirstPage && description != null)
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
            ],
          ),
          if (isFirstPage)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  'assets/ramalogoapp.png', // Make sure to update the path to your image
                  width: 150.0, // You can adjust the width and height as needed
                  height: 150.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
