import 'package:farm_sync/screens/social.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'bot.dart';
import 'crop.dart';
import 'disease_detector.dart';
import 'find.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Icon(Icons.notifications, color: Colors.orangeAccent),
          SizedBox(width: 15),
          Icon(Icons.logout, color: Colors.black),
          SizedBox(width: 20),
        ],
        leading: Icon(Icons.account_circle, size: 35, color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 20,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          "FarmSync",
          style: GoogleFonts.ubuntu(
              textStyle: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w500)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildCard(
              'CropCare AI',
              'AI Plant Disease Predictor: Identify plant diseases accurately and quickly.',
              'assets/lottie/chip.json',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
            ),
            buildCard(
              'GovAid',
              'Your gateway to government initiatives. Access details, eligibility, and benefits seamlessly.',
              'assets/lottie/schemes.json',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Bot()),
                );
              },
            ),
            buildCard(
              'Connect',
              'Community Hub: Your centralized space for connecting, sharing resources, and fostering relationships within our vibrant community. Join us and engage today!',
              'assets/lottie/social.json',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Social()),
                );
              },
            ),
            buildCard(
              'CropAdvisor',
              'CropAdvisor: Tailored crop suggestions based on farming conditions, maximizing yields and sustainability. Empower your agricultural decisions today!',
              'assets/lottie/AIFarmer.json',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CropRecommendationPage()),
                );
              },
            ),
            buildCard(
              'Help Finder',
              'Connect: A feature facilitating seamless matching between employers and workers, streamlining recruitment processes for efficient hiring and job-seeking.',
              'assets/lottie/AnimationCropAI.json',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FindPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String title, String subtitle, String lottieAsset, Function() onPressed) {
    return Card(
      margin: EdgeInsets.all(15.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 120.0, // Adjust height as needed
            child: Lottie.asset(lottieAsset),
          ),
          Padding(
            padding: EdgeInsets.all(12.0), // Adjust padding as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: Colors.greenAccent,
                ),
                child: Text('Try Now'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
