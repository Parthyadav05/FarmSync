import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class FindPage extends StatefulWidget {
  const FindPage({Key? key}) : super(key: key);

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isListVisible = true;

  Future<void> addWorker(String name, String phoneNumber, String area) async {
    await firestore.collection('users').doc(phoneNumber).set({
      'name': name,
      'phoneNumber': phoneNumber,
      'role': 'worker',
      'status': 'open',
      'area': area,
    });
    print('Worker listed successfully');
  }

  Future<void> addEmployer(String name, String phoneNumber, String area) async {
    await firestore.collection('users').doc(phoneNumber).set({
      'name': name,
      'phoneNumber': phoneNumber,
      'role': 'employer',
      'area': area
    });
    print('Employer listed successfully');
  }

  Future<void> updateWorkerStatus(String phoneNumber, bool status) async {
    await firestore.collection('users').doc(phoneNumber).update({
      'status': status ? 'open' : 'busy',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: TextField(
          enabled: true,
          controller: searchController,
          decoration: InputDecoration(
              suffixIcon: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
              labelText: "Search",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),

        ),
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              enabled: true,
              controller: nameController,
              decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                  )),
            ),
            SizedBox(height: 16.0),
            TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: "Phone No.",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                )),
            SizedBox(height: 16.0),
            TextField(
              enabled: true,
              controller: areaController,
              decoration: InputDecoration(
                  labelText: "Area",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)
                  )),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text;
                    String phoneNumber = phoneNumberController.text;
                    String area = areaController.text;
                    if (name.isNotEmpty && phoneNumber.isNotEmpty && area.isNotEmpty) {
                      await addWorker(name, phoneNumber, area);
                    }
                  },
                  child: Text('List as Worker'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text;
                    String phoneNumber = phoneNumberController.text;
                    String area = areaController.text;
                    if (name.isNotEmpty && phoneNumber.isNotEmpty) {
                      await addEmployer(name, phoneNumber, area);
                    }
                  },
                  child: Text('List as Employer'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Visibility(
              visible: isListVisible,
              child: Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    List<DocumentSnapshot> users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> userData =
                        users[index].data() as Map<String, dynamic>;
                        bool isOpen = userData['status'] == 'open';
                        bool hasSameArea = userData['area'] == areaController.text.toLowerCase().trim();
                        Color tileColor = hasSameArea ? Colors.green : Colors.grey; // Updated line
                        return GestureDetector(
                          onDoubleTap: () async {
                            await FlutterPhoneDirectCaller.callNumber(userData['phoneNumber']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              title: Text(userData['name']),
                              subtitle: Text(userData['phoneNumber']),
                              leading: Text(userData['area']),
                              tileColor: tileColor, // Updated line
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(userData['role']),
                                  SizedBox(width: 10),
                                  Switch(
                                    value: isOpen,
                                    onChanged: (value) {
                                      updateWorkerStatus(userData['phoneNumber'], value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
