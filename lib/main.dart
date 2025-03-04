import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'dart:async';
import 'colors.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Flutter Medical Solution',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          home: SliderSplashScreen(),
        );
      },
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
    Future.delayed(Duration(seconds: 3), () {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  List<Widget> _pages = [
    SplashPage(
      imagePath: 'assets/splash/splashscreenlogo.png',
      isFirstPage: true,
    ),
    SplashPage(
      imagePath: 'assets/splash/splash2.png',
      title: 'Care Beyond Boundaries',
      isCustomTitle: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return WillPopScope(
      onWillPop: () async => _splashSeen,
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
              itemBuilder: (context, index) => _pages[index],
            ),
            if (_currentPage != 0)
              Positioned(
                bottom: isLandscape ? 6.h : 2.h,
                left: isLandscape ? 5.w : 4.w,
                child: Row(
                  children: List.generate(_pages.length - 1, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      height: 1.2.h,
                      width: (_currentPage - 1) == index ? 4.w : 2.w,
                      decoration: BoxDecoration(
                        color: (_currentPage - 1) == index ? Colors.teal : Colors.green,
                        borderRadius: BorderRadius.circular(1.w),
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
  final String? title;
  final bool isFirstPage;
  final bool isCustomTitle;

  SplashPage({
    required this.imagePath,
    this.title,
    this.isFirstPage = false,
    this.isCustomTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 10.w : 5.w),
      child: Center(
        child: Column(
          mainAxisAlignment: isLandscape ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            SizedBox(height: isLandscape ? 5.h : 2.h), // Adjusted top padding for landscape
            Image.asset(
              imagePath,
              width: isLandscape ? 40.w : 70.w,
              height: isLandscape ? 30.h : 45.h,
            ),
            if (!isFirstPage)
              if (isCustomTitle)
                Padding(
                  padding: EdgeInsets.only(top: isLandscape ? 3.h : 2.h),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: title!.split(' ').map((word) {
                        Color color = AppColors.secondaryColor;
                        if (word == 'Care' || word == 'Boundaries') {
                          color = AppColors.primaryColor;
                        } else if (word == 'Beyond') {
                          color = AppColors.secondaryColor;
                        }
                        return TextSpan(
                          text: word + ' ',
                          style: TextStyle(
                            fontSize: isLandscape ? 3.5.w : 6.w,
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontFamily: 'Poppins',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            if (!isFirstPage)
              SizedBox(height: isLandscape ? 4.h : 2.h),
          ],
        ),
      ),
    );
  }
}
