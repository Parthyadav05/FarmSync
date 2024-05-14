import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_gemini/src/models/candidates/candidates.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:timelines/timelines.dart';

class CropRecommendationPage extends StatefulWidget {
  @override
  _CropRecommendationPageState createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage> {
  late String _location = '';
  late int _selectedMonth = DateTime.now().month;
  bool isLoading = false;
  bool isError = false;
  Gemini _gemini = Gemini.instance;
  String? _geminiResponse;

  @override
  void initState() {
    super.initState();
    _gemini = Gemini.instance;
  }

  Future<String> _getCityName(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    return placemarks.first.locality ?? '';
  }

  loc.LocationData? _locationData;

  Future<void> _getLocation() async {
    loc.Location location = loc.Location();
    bool _serviceEnabled;
    permission.PermissionStatus permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    permissionGranted = await permission.Permission.location.request();
    if (permissionGranted != permission.PermissionStatus.granted) {
      return;
    }

    _locationData = await location.getLocation();
    final cityName = await _getCityName(_locationData!.latitude!, _locationData!.longitude!);
    setState(() {
      _location = cityName;
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    final int? pickedMonth = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select Month'),
          children: List.generate(12, (index) {
            final month = index + 1;
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, month);
              },
              child: Text('${_getMonthName(month)}'),
            );
          }),
        );
      },
    );
    if (pickedMonth != null && pickedMonth >= 1 && pickedMonth <= 12) {
      setState(() {
        _selectedMonth = pickedMonth;

      });
    }
  }
  List<String> step = ["Select Location" , "Select Month" , "Click to get Recommendations"];
  String _getMonthName(int month) {
    return DateTime(DateTime.now().year, month).toString().split(' ')[0];
  }

  Future<void> _recommendCrops() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final cityName = await _getCityName(_locationData!.latitude!, _locationData!.longitude!);
      final regionSoilResponse = await _getLocationRegionSoilType(cityName);
      final region = regionSoilResponse['region'];
      final soilType = regionSoilResponse['soilType'];

      if (region!.isNotEmpty && soilType!.isNotEmpty && _selectedMonth >= 1 && _selectedMonth <= 12) {
        Candidates? response = await _gemini.text(
            "Generate Top crops to cultivate in this $region, $soilType and $_selectedMonth month rate the top five crops to grow according to $cityName in terms of profit for farmer for 10 thousand invested how much profit it will give for every crop");
        if (response != null &&
            response.content != null &&
            response.content!.parts != null &&
            response.content!.parts!.isNotEmpty) {
          final geminiResponse = response.content!;
          setState(() {
            isLoading = false;
            _geminiResponse = geminiResponse.parts!.map((part) => part.text).join('\n');
          });
        } else {
          throw Exception('No valid response from Gemini');
        }
      } else {
        throw Exception('Could not determine region and soil type from location or invalid month selected');
      }
    } catch (error) {
      setState(() {
        isError = true;
      });
      print('Error: $error');
    }
  }

  Future<Map<String, String>> _getLocationRegionSoilType(String location) async {
    final prompt = 'Generate the soil type for $location in one word';
    Candidates? response = await _gemini.text(prompt);
    String region = '';
    String soilType = ' ';

    if (response != null &&
        response.content != null &&
        response.content!.parts != null &&
        response.content!.parts!.isNotEmpty) {
      region = location;
      soilType = response.output.toString();
    }
    return {'region': region, 'soilType': soilType};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CropMaster'),
        elevation: 30,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _getLocation,
                  child: Text('Select Location'),
                ),
                SizedBox(width: 30),
                ElevatedButton(
                  onPressed: () => _selectMonth(context),
                  child: Text('Select Month'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              children: [
                Row(children: [
                  Text('Selected Location: $_location' , ),Icon(Icons.location_on,color: Colors.red,)],),
                SizedBox(height: 10),
                Row(children: [Text('Selected Month: ${_getMonthName(_selectedMonth)}'), Icon(Icons.calendar_month, color: Colors.blue,)],),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isError ? null : _recommendCrops,
              child: Text('Get Recommendations'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GeminiResponseTypeView(
                builder: (context, child, _response, isUser) {
                  if (!isUser) {
                    return Center(child:
                      Column(
                        children: [
                          SizedBox(height: 50,),
                          Icon(Icons.location_on , size: 250,color: Colors.red,),
                          Text("Select Location and Month",style: GoogleFonts.ubuntu(
                          ),),
                        ],
                      )
                      ,);
                  }
                  if (_response != null) {
                    return Markdown(
                      data: _response,
                      selectable: true,
                    );
                  } else {
                    return  Center(child: Lottie.asset("assets/lottie/load.json"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
