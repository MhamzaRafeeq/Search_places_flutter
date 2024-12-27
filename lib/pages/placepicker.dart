import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_projects/consts.dart';
import 'package:geocoding/geocoding.dart';



class Placepicker extends StatefulWidget {
  const Placepicker({super.key});

  @override
  State<Placepicker> createState() => _PlacepickerState();
}

class _PlacepickerState extends State<Placepicker> {
  TextEditingController _controller = TextEditingController();
  Uuid uuid  = Uuid();
  String _sessionToken = '12345';
  List<dynamic> _placesList=  [];
  double? Latitude = null;
  double? Longitude = null;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener((){
      onChange();
    });
  }

  void onChange(){
    if(_sessionToken == null){
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  void getSuggestion(String input) async{
    String google_places_api_key = GOOGLE_API_KEY;
    String baseURL = BASEURL;
    String request = '$baseURL?input=$input&key=$google_places_api_key&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));

    // String data = response.body.toString();
    // print('data');
    // print(data);
    if(response.statusCode == 200){
      setState(() {
        _placesList = jsonDecode(response.body.toString()) ['predictions'];
      });
    }else{
      throw Exception('Failed to load data');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Google Search Places Api'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search Place',
                label: Text('placepicer'),
              ),
            ),
            Expanded(child: ListView.builder(
              itemCount: _placesList.length,
                itemBuilder: (context, index){
              return ListTile(
                title: Text(_placesList[index]['description']),
                onTap: () async{
                  String address = _placesList[index]['description'];
                  List<Location> locations = await locationFromAddress(address);
                  // setState(() {
                  //   Latitude = locations.first.latitude;
                  //   Longitude = locations.first.longitude;
                  // });
                   print(locations);
                },
                // trailing: Text('$Latitude, $Longitude'),
              );
            }))
          ],
        ),
      ),
    );
  }
}
