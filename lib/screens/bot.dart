import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class Bot extends StatefulWidget {
  const Bot({Key? key}) : super(key: key);

  @override
  State<Bot> createState() => _BotState();
}

class _BotState extends State<Bot> {
  bool flag = true;
  Gemini _gemini = Gemini.instance;
  String _response = '';

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      // If a message is provided, send it to the bot
      _gemini.text(message).then((response) {
        setState(() {
          _response = response?.output ?? "No response from the bot.";
        });
      }).catchError((error) {
        setState(() {
          _response = "Error: $error";
        });
      });
    } else {
      // If no message is provided, handle chip selection
      String selectedCrop = crops[_value];
      // Simulate fetching schemes and subsidies based on selected crop
      String schemesAndSubsidies = fetchSchemesAndSubsidies(selectedCrop);
      setState(() {
        _response = schemesAndSubsidies;
      });
    }
  }

  int _value = 0;
  List<String> crops = [
    "millets",
    "coffee nuts",
    "tea",
    "nuts",
    "spices",
    "cereals",
    "onion",
    "rice",
    "wheat"
  ];

  String fetchSchemesAndSubsidies(String crop) {
    // This function would ideally fetch schemes and subsidies from a data source
    // based on the selected crop. For simplicity, we'll just return a static string here.
    // You should replace this with your actual data fetching logic.
    switch (crop) {
      case "millets":
        return "Government schemes and subsidies for millets in India and application link and eligibility and youtube videos for more context: ...";
      case "coffee nuts":
        return "Government schemes and subsidies for coffee nuts in India and application link and eligibility and youtube videos for more context: ..";
      case "tea":
        return "Government schemes and subsidies for tea in India and application link and eligibility and youtube videos for more context: ..";
      case "nuts":
        return "Government schemes and subsidies for nuts in India and application link and eligibility and youtube videos for more context: ..";
      case "spices":
        return "Government schemes and subsidies for coffee spices in India and application link and eligibility and youtube videos for more context: ..";
      case "cereals":
        return "Government schemes and subsidies for cereals in India and application link and eligibility and  youtube videos for more context: ..";
      case "onion":
        return "Government schemes and subsidies for nuts in India and application link and eligibility and youtube videos for more context: ..";
      case "rice":
        return "Government schemes and subsidies for coffee spices in India and application link and eligibility and youtube videos for more context: ..";
      case "wheat":
        return "Government schemes and subsidies for cereals in India and application link and eligibility and youtube videos for more context: ..";
      default:
        return "No schemes and subsidies found for this crop.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        bottomOpacity: 0.5,
        title: Text("Government Schemes"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                flag = !flag;
              });
            },
            icon: FaIcon(FontAwesomeIcons.language, color: Colors.lightBlue),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10.0),
          Neumorphic(
            child: Wrap(
              spacing: 10.0,
              runSpacing: 8,
              children: List<Widget>.generate(
                crops.length,
                    (int index) {
                  return Neumorphic(
                    style: NeumorphicStyle(
                      lightSource: LightSource.top
                    ),
                    child: ChoiceChip(
                      label: Text(crops[index]),
                      selected: _value == index,
                      onSelected: (bool selected) {
                        setState(() {
                          _value = (selected ? index : null)!;
                          sendMessage(fetchSchemesAndSubsidies(crops[index]));
                        });
                      },
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          Expanded(
            child: GeminiResponseTypeView(
              builder: (context, child, _response, isUser) {
                if (!isUser) {
                  return Center(child: CircularProgressIndicator());
                }
                if (_response != null) {
                  return Markdown(
                    data: _response,
                    selectable: true,
                  );
                } else {
                  return const Center(child: Text('Please Wait!!!!'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
