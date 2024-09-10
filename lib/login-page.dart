import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensi/home-page.dart';
import 'package:presensi/models/login-response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? Key}) : super(key: Key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  //late Future<String> _name,_token;

  @override
  void initState() {
     super.initState();
    // _token = _prefs.then((SharedPreferences prefs){
    //   return prefs.getString("token") ?? "";
    // });

    // _name = _prefs.then((SharedPreferences prefs){
    //   return prefs.getString("name") ?? "";
    // });

    //checkToken(_token, _name);
    _checkToken();
  }

  Future<void> _checkToken() async{
    final SharedPreferences prefs = await _prefs;
    String? token = prefs.getString("token");
    String? name = prefs.getString("name");

    if (token != null && token.isNotEmpty && name != null && name.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } 
  }

  Future<void> login(String email, String password) async {
    Map<String, String> body = {"email": email, "password": password};
    var response = await myHttp.post(
      Uri.parse('http://127.0.0.1:8000/api/login'), // Login API
      body: body,
    );

    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email atau Password Salah!")),
      );
    } else {
      var loginResponseModel = LoginResponseModel.fromJson(json.decode(response.body));
      await _saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _saveUser(String token, String name) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString("name", name);
    await prefs.setString("token", token);
  }

  // Future login(email,password) async{
  //   LoginResponseModel? loginResponsemodel;
  //   Map<String, String> body = {"email": email, "password": password};
  //   var response = await myHttp.post(
  //     Uri.parse('http://127.0.0.1:8000/api/login'),//Get Http
  //     body: body,
  //     );
  //     if(response.statusCode == 401){
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email atau Password Salah!")));
  //     }else{
  //       loginResponsemodel = LoginResponseModel.fromJson(json.decode(response.body));
  //       saveUser(loginResponsemodel.data.token, loginResponsemodel.data.name);
  //     }
  // }

  // checkToken(token, name) async{
  //   String tokenStr = await token;
  //   String nameStr = await name;
  //   if(tokenStr != "" && nameStr != ""){
  //     Future.delayed(Duration(seconds: 1), () async{
  //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()))
  //       .then((value){
  //         setState(() {});
  //       });
  //     });
  //   }
  // }

  // Future saveUser(token, name) async {
  //   try{
  //   final SharedPreferences pref = await _prefs;
  //   pref.setString("name", name);
  //   pref.setString("token", token);
  //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()))
  //       .then((value){
  //         setState(() {});
  //       });
  //   }catch(e){
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Text("Login Sistem Absensi Sungai Sibam")),
                SizedBox(height: 20),
                Text("Email"),
                TextField(controller: emailController),
                SizedBox(height: 20),
                Text("Password"),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(onPressed:(){
                  login(emailController.text,passwordController.text);
                }, child: Text("Masuk"))
              ],
            ),
          ),
        )),
    );
  }
}