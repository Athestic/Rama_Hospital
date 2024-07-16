import 'package:flutter/material.dart';
import 'doctor_login.dart';
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

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
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
    // SplashPage(
    //   imagePath: 'assets/splash/splash1.png',
    //   title: 'Connect With \n Rama Pulse',
    //   description: 'Compassionate Care for All',
    // ),
    SplashPage(
      imagePath: 'assets/splash/splash2.png',
      title: 'Advanced Patient \n Care',
      description: 'Comprehensive Treatment Solutions',
    ),
    SplashPage(
      imagePath: 'assets/splash/splash3.png',
      title: 'Expert \n Medical Team',
      description: 'Dedicated to Your Health',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
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
          Positioned(
            bottom: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  height: 10.0,
                  width: _currentPage == index ? 20.0 : 10.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey,
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
              duration: Duration(milliseconds: 500),
              curve: Curves.easeIn,
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        },
        child: Icon(Icons.arrow_forward),
        backgroundColor: AppColors.primaryColor,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class SplashPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isFirstPage;

  SplashPage({
    required this.imagePath,
    required this.title,
    required this.description,
    this.isFirstPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath),
                SizedBox(height: 20.0),
                if (isFirstPage)
                  RichText(
                    text: TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                          text: 'Rama',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextSpan(
                          text: 'Pulse',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                SizedBox(height: 10.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isFirstPage)
          Positioned(
            bottom: 40.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
      ],
    );
  }
}
