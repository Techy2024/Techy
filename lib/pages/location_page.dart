import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _location = '正在獲取位置...';
  Timer? _timer;
  final int _intervalInMinutes = 30; // 設定間隔時間

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _timer = Timer.periodic(Duration(seconds: _intervalInMinutes), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 檢查定位服務是否啟用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = '定位服務未啟用';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = '定位權限被拒絕';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = '定位權限被永久拒絕';
        return;
      });
    }

    // 獲取現在位置
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 使用 geocoding 將經緯度轉換為地址
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // 提取地址資訊
    Placemark place = placemarks[0];
    String address =
        '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

    // 獲取當前使用者 UID
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // 獲取當前時間
      Timestamp timestamp = Timestamp.now();

      // 將位置信息儲存到 Firestore
      await FirebaseFirestore.instance
          .collection('UserID')
          .doc(uid)
          .collection('User_Locations')
          .doc(timestamp.toString())
          .set({
        'longitude': position.longitude,
        'latitude': position.latitude,
        'address': address,
        'timestamp': timestamp,
      });

      setState(() {
        _location =
            '經度: ${position.longitude}, 緯度: ${position.latitude}, 地址: $address';
      });
    } else {
      setState(() {
        _location = '無法獲取使用者資訊';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '您的目前位置:',
            ),
            Text(
              _location,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
