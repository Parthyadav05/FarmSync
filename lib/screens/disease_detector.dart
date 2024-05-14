import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter interpreter;
  bool _modelLoaded = false;
  final apiKey =
      Platform.environment[''];
  final model = GenerativeModel(
      model: 'gemini-pro', apiKey: '');
  var generatedText = "";
  // Create a list of strings containing only the disease names
  // Add all supported characters
  List<String> vocabulary = [
    "Apple__black_rot",
    "Apple__healthy",
    "Apple__rust",
    "Apple__scab",
    "Cassava__bacterial_blight",
    "Cassava__brown_streak_disease",
    "Cassava__green_mottle",
    "Cassava__healthy",
    "Cassava__mosaic_disease",
    "Cherry__healthy",
    "Cherry__powdery_mildew",
    "Chili__healthy",
    "Chili__leaf_curl",
    "Chili__leaf_spot",
    "Chili__whitefly",
    "Chili__yellowish",
    "Coffee__cercospora_leaf_spot",
    "Coffee__healthy",
    "Coffee__red_spider_mite",
    "Coffee__rust",
    "Corn__common_rust",
    "Corn__gray_leaf_spot",
    "Corn__healthy",
    "Corn__northern_leaf_blight",
    "Cucumber__diseased",
    "Cucumber__healthy",
    "Gauva__diseased",
    "Gauva__healthy",
    "Grape__black_measles",
    "Grape__black_rot",
    "Grape__healthy",
    "Grape__leaf_blight_(isariopsis_leaf_spot)",
    "Jamun__diseased",
    "Jamun__healthy",
    "Lemon__diseased",
    "Lemon__healthy",
    "Mango__diseased",
    "Mango__healthy",
    "Peach__bacterial_spot",
    "Peach__healthy",
    "Pepper_bell__bacterial_spot",
    "Pepper_bell__healthy",
    "Pomegranate__diseased",
    "Pomegranate__healthy",
    "Potato__early_blight",
    "Potato__healthy",
    "Potato__late_blight",
    "Rice__brown_spot",
    "Rice__healthy",
    "Rice__hispa",
    "Rice__leaf_blast",
    "Rice__neck_blast",
    "Soybean__bacterial_blight",
    "Soybean__caterpillar",
    "Soybean__diabrotica_speciosa",
    "Soybean__downy_mildew",
    "Soybean__healthy",
    "Soybean__mosaic_virus",
    "Soybean__powdery_mildew",
    "Soybean__rust",
    "Soybean__southern_blight",
    "Strawberry___leaf_scorch",
    "Strawberry__healthy",
    "Sugarcane__bacterial_blight",
    "Sugarcane__healthy",
    "Sugarcane__red_rot",
    "Sugarcane__red_stripe",
    "Sugarcane__rust",
    "Tea__algal_leaf",
    "Tea__anthracnose",
    "Tea__bird_eye_spot",
    "Tea__brown_blight",
    "Tea__healthy",
    "Tea__red_leaf_spot",
    "Tomato__bacterial_spot",
    "Tomato__early_blight",
    "Tomato__healthy",
    "Tomato__late_blight",
    "Tomato__leaf_mold",
    "Tomato__mosaic_virus",
    "Tomato__septoria_leaf_spot",
    "Tomato__spider_mites_(two_spotted_spider_mite)",
    "Tomato__target_spot",
    "Tomato__yellow_leaf_curl_virus",
    "Wheat__brown_rust",
    "Wheat__healthy",
    "Wheat__septoria",
    "Wheat__yellow_rust"
  ];
  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/model.tflite');
      setState(() {
        _modelLoaded = true;
      });
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  File? _image;
  String _outputText = '';
  final picker = ImagePicker();
  late var pickedImage;
  Future<void> pickImage() async {
    pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Process the picked image
      processImage();
    }
  }

  Future<void> showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              pickImage();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  Future<void> getImageFromCamera() async {
    pickedImage = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      }
    });
    processImage();
  }

  Future<void> processImage() async {
    if (_image == null || !_modelLoaded) return;

    try {
      // Preprocess the image
      var input = await resizeAndPreprocessImage(_image!.path);

      // Run inference
      var output = Float32List(
          1 * 38); // Adjust the size based on the model output shape
      interpreter.run(input.buffer, output.buffer);

      // Process the output
      _outputText = processOutput(output, 1);
      setState(() {
        print(_outputText);
      });
    } catch (e) {
      print('Error during inference: $e');
    }
  }

  Future<Float32List> resizeAndPreprocessImage(String imagePath) async {
    // Read the image file
    String key = "AIzaSyA3FJobqtEW7ovd7yF_cYHt7Xlx5U6QUu8";
    final imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      throw Exception('Image file does not exist');
    }

    final imageBytes = imageFile.readAsBytesSync();
    final img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize the image to 224x224
    final img.Image resizedImage =
        img.copyResize(image, width: 128, height: 128);

    // Normalize pixel values to range [0, 1]
    var input = Float32List(1 * 128 * 128 * 3);
    var buffer = input.buffer;
    var pixels = buffer.asFloat32List();

    for (int y = 0; y < 128; y++) {
      for (int x = 0; x < 128; x++) {
        var pixel = resizedImage.getPixel(x, y);
        pixels[(y * 128 + x) * 3 + 0] = (img.getLuminance(pixel)) / 255.0;
        pixels[(y * 128 + x) * 3 + 1] = (img.getLuminance(pixel)) / 255.0;
        pixels[(y * 128 + x) * 3 + 2] = (img.getLuminance(pixel)) / 255.0;
      }
    }

    return input;
  }

  String processOutput(Float32List output, int k) {
    // Sort the output values in descending order
    List<MapEntry<int, double>> sortedOutput = output.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get the top-k predicted characters with their probabilities
    List<String> topKChars = [];
    List<double> topKProbs = [];
    for (int i = 0; i < k && i < output.length; i++) {
      int index = sortedOutput[i].key;
      String predictedChar = vocabulary[index];
      double prob = sortedOutput[i].value;
      topKChars.add(predictedChar);
      topKProbs.add(prob);
    }

    // Return the top-k predicted characters with their probabilities
    return topKChars.join(', ') + ' (' + topKProbs.join(', ') + ')';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 10,
          bottomOpacity: 0.5,
          title: Text('CropCare AI',
              style: GoogleFonts.ubuntu(
                  textStyle: TextStyle(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)))),
      body: Container(
        color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null
                    ? Lottie.asset("assets/lottie/ai.json")
                    : ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                           fit: BoxFit.cover,
                          _image!,
                          height: 200,
                        ),
                    ),
                SizedBox(
                  height: 20,
                ),
                Text(_outputText , style: TextStyle(
                  color: Colors.white
                ),),
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    const SizedBox(width: 40),
                    NeumorphicButton(
                      style: NeumorphicStyle(lightSource: LightSource.bottom),
                      onPressed: showOptions,
                      child: const Text(
                        'Edit Image',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                    const SizedBox(width: 20),
                    NeumorphicButton(
                        style: NeumorphicStyle(lightSource: LightSource.bottom),
                        onPressed: () async {
                          final content = [
                            Content.text(
                              'Your task is to generate an organic solution for the plant disease as a summary in one paragraph:$_outputText',
                            )
                          ];
                          final response = await model.generateContent(content);
                          setState(() {
                            generatedText = response.text!;
                          });
                          print(response.text);
                        },
                        child: Text(
                          "Organic Solution",
                          style: TextStyle(color: Colors.teal.shade500),
                        )),
                  ],
                ),
                _outputText == ''
                    ? SizedBox()
                    : Column(
                        children: [
                          generatedText != ""
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: BubbleSpecialOne(
                                    sent: true,
                                    delivered: true,
                                    text: generatedText,
                                    color: const Color(0xFFE8E8EE),
                                    tail: true,
                                    isSender: false,
                                  ),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: NeumorphicText(
                                    "Get an Organic Solution",
                                    textAlign: TextAlign.center,
                                    textStyle: NeumorphicTextStyle(
                                        height: 4,
                                        letterSpacing: 6,
                                        fontSize: 18),
                                  ),
                                ),
                          generatedText != ""
                              ? ToggleSwitch(
                                  animate: true,
                                  curve: Curves.linear,
                                  minWidth: 90.0,
                                  minHeight: 20.0,
                                  initialLabelIndex: 0,
                                  cornerRadius: 20.0,
                                  activeFgColor: Colors.white,
                                  inactiveBgColor: Colors.grey,
                                  inactiveFgColor: Colors.white,
                                  totalSwitches:
                                      2, // Adjusted to match the number of labels
                                  labels: ["हिंदी", "English"],
                                  borderColor: [
                                    Color(0xff3b5998),
                                    Color(0xff8b9dc3)
                                  ],
                                  dividerColor: Colors.blueGrey,
                                  activeBgColors: [
                                    [Color(0xff3b5998), Color(0xff8b9dc3)],
                                    [Color(0xff00aeff), Color(0xff0077f2)]
                                  ],
                                  onToggle: (index) async {
                                    String language = "English";
                                    switch (index) {
                                      case 0:
                                        language =
                                            'Hindi'; // Use 'hi' for Hindi
                                        break;
                                      case 1:
                                        language =
                                            'English'; // Use 'en' for English
                                        break;
                                    }

                                    final content = [
                                      Content.text(
                                        'Translate the generated text in $language: $generatedText',
                                      )
                                    ];
                                    final response =
                                        await model.generateContent(content);
                                    setState(() {
                                      generatedText = response.text ?? '';
                                    });
                                  },
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
