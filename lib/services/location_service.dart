import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService extends ChangeNotifier {
  String _location = '正在獲取位置...';
  Timer? _timer; // 定時器
  Duration updateInterval = const Duration(seconds: 30); // 設定 30 秒的更新間隔

  String get location => _location;

  LocationService() {
    _startLocationTracking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLocationTracking() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      // 提示用戶啟用位置服務
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    _timer = Timer.periodic(updateInterval, (Timer t) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(position);
    });
  }

  Future<void> _updateLocation(Position position) async {
    // 使用 geocoding 將經緯度轉換為地址
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    String address =
        '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

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

      _location =
          '經度: ${position.longitude}, 緯度: ${position.latitude}, 地址: $address';
    } else {
      _location = '無法獲取使用者資訊';
    }

    notifyListeners(); // 通知所有監聽這個狀態的 widget 更新
  }
}
