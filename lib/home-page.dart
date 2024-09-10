import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/login-page.dart';
import 'package:presensi/models/home-response.dart';
import 'package:presensi/models/logout-response.dart';
import 'package:presensi/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;


class HomePage extends StatefulWidget {
  const HomePage({Key? key}): super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name,_token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs){
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs){
      return prefs.getString("name") ?? "";
    });
  }

  Future logOut() async{
    final Map<String, String> headers = {
      'Authorization' : 'Bearer ' + await _token
    };
    LogoutResponseModel logoutResponseModel;
    var response = await myHttp.post(Uri.parse('http://127.0.0.1:8000/api/logout'),headers: headers);//Post Logout
    logoutResponseModel = LogoutResponseModel.fromJson(json.decode(response.body));
    if(response.statusCode == 200){
      final SharedPreferences prefs = await _prefs;
      await prefs.clear();//clear stored token and user data
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()),(Route route) => false);//removes all previous route
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(logoutResponseModel.message)));
    }
  }

  Future getData() async {
  final Map<String, String> headers = {
    'Authorization': 'Bearer ' + await _token
  };
  var response = await myHttp.get(
    Uri.parse('http://127.0.0.1:8000/api/get-presensi'), // Get Http 
    headers: headers
  );
  
  homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
  riwayat.clear();
  
  homeResponseModel!.data.forEach((element) {
    if (element.isHariIni) {
      hariIni = element;
      // Ensure 'pulang' is empty if it's not set for today
      if (hariIni!.pulang.isEmpty || hariIni!.pulang == null) {
        hariIni!.pulang = ''; 
      }
    } else {
      riwayat.add(element);
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapShot){
          if(snapShot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          else{
             return SafeArea(
            child:  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(onPressed:(){
                    logOut();
                  }, child: Text("Logout"),style: ButtonStyle(alignment: Alignment.topCenter),),
                  SizedBox(
                    height: 20,
                  ),
                  FutureBuilder(
                    future: _name,
                    builder: (BuildContext context,AsyncSnapshot<String> snapShot){
                      if(snapShot.connectionState == ConnectionState.waiting){
                        return CircularProgressIndicator();
                      }else{
                        if(snapShot.hasData){
                          return Text("Selamat Datang, "+snapShot.data!, style: TextStyle(fontSize: 18),textAlign:TextAlign.center);
                        }else{
                          return Text("-",style: TextStyle(fontSize: 18));
                        }
                      }
                    }
                  ),
                  SizedBox(
                    height: 20,
                    ),
                  Container(
                  width: double.infinity,
                  decoration : BoxDecoration(color: Colors.blue[800]), 
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children:[
                      Text(hariIni?.tanggal ?? '-', 
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [Text(hariIni?.masuk ?? '-', 
                              style: 
                                TextStyle(color: Colors.white, fontSize: 24)), 
                            Text("MASUK",
                              style: 
                                TextStyle(color: Colors.white, fontSize: 16))
                                ],
                          ),
                          Column(
                            children: [Text(hariIni?.pulang ?? '-', 
                              style: 
                                TextStyle(color: Colors.white, fontSize: 24)), 
                            Text("PULANG",
                              style: 
                                TextStyle(color: Colors.white, fontSize: 16))
                                ],
                          ),
                      ],
                      )
                    ]),
                  ),
                  ),
                  SizedBox(height: 20),
                  Text("Riwayat Presensi"),
                  Expanded(
                    child: ListView.builder(
                      itemCount: riwayat.length,
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: Text(riwayat[index].tanggal),
                          title : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children:[
                            Column(
                                  children:[
                                  Text(riwayat[index].masuk,style: TextStyle(fontSize: 24)), 
                                  Text("MASUK",style: TextStyle(fontSize: 16))
                                  ],
                                ),
                            //SizedBox(),
                            Column(
                                  children:[
                                  Text(riwayat[index].pulang,style: TextStyle(fontSize: 24)), 
                                  Text("PULANG",style: TextStyle(fontSize: 16))
                                  ],
                                ),
                          ],)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          );
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SimpanPage())).then((value){
            setState(() {});
          });
        },
        child: Icon(Icons.add)
        ),  
    );
  }
}
