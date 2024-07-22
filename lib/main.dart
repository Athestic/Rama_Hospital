import 'package:flutter/material.dart';
import 'view_all_doctors.dart';
import 'package:bottom_navigation/Homepage.dart';
import 'dart:async';
import 'colors.dart';
import 'package:lottie/lottie.dart';

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
    Future.delayed(Duration(seconds: 2), () {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  List<Widget> _pages = [
    AnimatedSplashPage(
      imagePath: 'assets/Ramalogo.jpeg',
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

class AnimatedSplashPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isFirstPage;

  AnimatedSplashPage({
    required this.imagePath,
    required this.title,
    required this.description,
    this.isFirstPage = false,
  });

  @override
  _AnimatedSplashPageState createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    );
    _controller.forward().then((_) {
      if (widget.isFirstPage) {
        Timer(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SliderSplashScreen()));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset(0, 0),
      ).animate(_controller),
      child: SplashPage(
        imagePath: widget.imagePath,
        title: widget.title,
        description: widget.description,
        isFirstPage: widget.isFirstPage,
        animation: _animation,
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final bool isFirstPage;
  final bool isCustomTitle;
  final Animation<double>? animation;

  SplashPage({
    required this.imagePath,
    required this.title,
    required this.description,
    this.isFirstPage = false,
    this.isCustomTitle = false,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFirstPage)
            ScaleTransition(
              scale: animation!,
              child: Image.asset(imagePath),
            )
          else ...[
            Image.asset(imagePath),
            // Spacer(),  // Add space between the image and the text/description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (isCustomTitle)
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
                  SizedBox(height: 10.0),  // Space between title and description
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
