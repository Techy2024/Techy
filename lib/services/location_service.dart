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
    _scheduleMidnightTask();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLocationTracking() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
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
          '地址: $address';
    } else {
      _location = '無法獲取使用者資訊';
    }

    notifyListeners(); // 通知所有監聽這個狀態的 widget 更新
  }
  // 計算固定行程
   bool _isSameLocation(Map<String, dynamic> loc1, Map<String, dynamic> loc2, double tolerance) {
    double lat1 = loc1['latitude'] as double;
    double lon1 = loc1['longitude'] as double;
    double lat2 = loc2['latitude'] as double;
    double lon2 = loc2['longitude'] as double;

    return (lat1 - lat2).abs() <= tolerance && (lon1 - lon2).abs() <= tolerance;
  }

  // 修改位置處理邏輯
  List<Map<String, dynamic>> processLocations(List<dynamic> locationData, {double tolerance = 0.001, int minConsecutive = 3}) {
    List<Map<String, dynamic>> fixedLocations = [];
    int consecutiveCount = 1;
    Map<String, dynamic>? startLocation;
    Timestamp? startTime;

    for (int i = 1; i < locationData.length; i++) {
      final currentLocation = locationData[i] as Map<String, dynamic>;
      final previousLocation = locationData[i - 1] as Map<String, dynamic>;

      if (_isSameLocation(currentLocation, previousLocation, tolerance)) {
        consecutiveCount++;
        if (consecutiveCount == minConsecutive) {
          startLocation = previousLocation;
          startTime = previousLocation['timestamp'] as Timestamp;
        }
        if (consecutiveCount >= minConsecutive && i == locationData.length - 1) {
          fixedLocations.add({
            'address': startLocation!['address'],
            'startTime': startTime,
            'endTime': currentLocation['timestamp'],
            'latitude': startLocation['latitude'],
            'longitude': startLocation['longitude']
          });
        }
      } else {
        if (consecutiveCount >= minConsecutive) {
          fixedLocations.add({
            'address': startLocation!['address'],
            'startTime': startTime,
            'endTime': previousLocation['timestamp'],
            'latitude': startLocation['latitude'],
            'longitude': startLocation['longitude']
          });
        }
        consecutiveCount = 1;
        startLocation = null;
        startTime = null;
      }
    }

    return fixedLocations;
  }

  // 定時每天00:00AM執行固定行程判斷
  void _scheduleMidnightTask() {
    final now = DateTime.now();
    // final nextMidnight = DateTime(now.year, now.month, now.day+1 , 0, 53, 0); // 設定下個00:00AM的時間
    // final durationUntilMidnight = nextMidnight.difference(now);
    
    // 測試：設置下一次定時器為現在時間的 5 秒後
    final nextMidnight = now.add(const Duration(minutes: 3));
    
    // 計算從現在到下一次觸發的時間差
    final durationUntilMidnight = nextMidnight.difference(now);
    
    print('現在時間: $now');
    print('下一次定時器時間: $nextMidnight');
    print('距離下一次執行的時間: $durationUntilMidnight');
    
    // 使用 Timer.periodic 來確保定時器會持續執行
    Timer? _midnightTimer;
    _midnightTimer = Timer(durationUntilMidnight, () async {
      print('開始執行定時任務');
      try {
        await _evaluateFixedLocations();
        print('定時任務執行完成');
      } catch (e) {
        print('定時任務執行錯誤: $e');
      }
      // 重新設置定時器
      _scheduleMidnightTask();
    });
  }

  // 評估固定行程
  Future<void> _evaluateFixedLocations() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      print('ccc');
      // 獲取今天的定位資料
      DateTime todayStart = DateTime.now().subtract(Duration(days: 1));
      DateTime todayEnd = DateTime.now();
      
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserID')
          .doc(uid)
          .collection('User_Locations')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();
      
      List<Map<String, dynamic>> locationData = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      
      // 處理這些定位資料，判斷固定行程
      List<Map<String, dynamic>> fixedLocations = processLocations(locationData);
  print('ddd');
      // 儲存固定行程資料
      for (var fixedLocation in fixedLocations) {
        await FirebaseFirestore.instance
            .collection('UserID')
            .doc(uid)
            .collection('User_Fixed_Locations')
            .add(fixedLocation);
      }
    }
  }
}
