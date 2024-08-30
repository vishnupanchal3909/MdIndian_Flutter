import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(HospitalApp());
}

class HospitalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HospitalListScreen(),
    );
  }
}

class HospitalListScreen extends StatefulWidget {
  @override
  _HospitalListScreenState createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  List<Hospital> hospitals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  Future<void> fetchHospitals() async {
    final url = Uri.parse(
        'http://mdiserviceweb.mdindia.com:8060/CommonAPIServiceWeb/WCFCommonServices.svc/rest/getLocationList?statename=Maharashtra&district=Pune&cityname=Pune&MobileUniqId=0000002');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['response']['data'];
      setState(() {
        hospitals = data.map((item) => Hospital.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load hospitals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitals List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return HospitalCard(
            hospital: hospital,
            backgroundColor: _getCardColor(index),
          );
        },
      ),
    );
  }

  Color _getCardColor(int index) {
    // Alternate card colors Red, Green, Blue
    switch (index % 3) {
      case 0:
        return Colors.red[100]!;
      case 1:
        return Colors.green[100]!;
      case 2:
        return Colors.blue[100]!;
      default:
        return Colors.white;
    }
  }
}

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final Color backgroundColor;

  HospitalCard({required this.hospital, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('Address: ${hospital.address}'),
            SizedBox(height: 5),
            Text('PIN Code: ${hospital.pinCode}'),
            SizedBox(height: 5),
            Text('Contact: ${hospital.contactDetails ?? "N/A"}'),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.location_on, color: Colors.blue),
                onPressed: () {
                  _openMap(hospital.latitude, hospital.longitude);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMap(String latitude, String longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the map.';
    }
  }
}

class Hospital {
  final String name;
  final String address;
  final String pinCode;
  final String? contactDetails;
  final String latitude;
  final String longitude;

  Hospital({
    required this.name,
    required this.address,
    required this.pinCode,
    required this.latitude,
    required this.longitude,
    this.contactDetails,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['HospitalName'] ?? 'N/A',
      address: json['HospitalAddress'] ?? 'N/A',
      pinCode: json['PinCode'] ?? 'N/A',
      contactDetails: json['Contact_Mobile_No'] ?? json['Tel_no'] ?? json['E_Mail'] ?? 'N/A',
      latitude: json['Latitude'] ?? '0.0',
      longitude: json['Longitude'] ?? '0.0',
    );
  }
}
