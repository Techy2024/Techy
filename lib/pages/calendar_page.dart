import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// 時間衝突解決器類
class TimeSlotResolver {
  // 檢查是否有時間衝突
  static bool hasTimeConflict(
      String start1, String end1, String start2, String end2) {
    final startTime1 = _parseTime(start1);
    final endTime1 = _parseTime(end1);
    final startTime2 = _parseTime(start2);
    final endTime2 = _parseTime(end2);

    return (startTime1.isBefore(endTime2) && endTime1.isAfter(startTime2));
  }

  // 解決時間衝突
  static List<Event> resolveTimeConflicts(List<Event> events) {
    if (events.isEmpty) return events;

    // 按開始時間排序
    events.sort(
        (a, b) => _parseTime(a.startTime).compareTo(_parseTime(b.startTime)));

    List<Event> resolvedEvents = [];
    Event? previousEvent = events[0];
    resolvedEvents.add(previousEvent);

    for (int i = 1; i < events.length; i++) {
      Event currentEvent = events[i];

      if (hasTimeConflict(previousEvent!.startTime, previousEvent.endTime,
          currentEvent.startTime, currentEvent.endTime)) {
        // 如果有衝突，將當前事件移到前一個事件結束後
        String newStartTime = previousEvent.endTime;
        String newEndTime = _addMinutesToTime(newStartTime,
            _getMinutesDuration(currentEvent.startTime, currentEvent.endTime));

        currentEvent = Event(
          name: currentEvent.name,
          startTime: newStartTime,
          endTime: newEndTime,
          location: currentEvent.location,
          id: currentEvent.id,
        );
      }

      resolvedEvents.add(currentEvent);
      previousEvent = currentEvent;
    }

    return resolvedEvents;
  }

  // 解析時間字符串為 DateTime
  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    return DateTime(2024, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  // 計算時間段的分鐘數
  static int _getMinutesDuration(String startTime, String endTime) {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    return end.difference(start).inMinutes;
  }

  // 給時間添加分鐘數
  static String _addMinutesToTime(String time, int minutes) {
    final DateTime dateTime = _parseTime(time);
    final newDateTime = dateTime.add(Duration(minutes: minutes));
    return '${newDateTime.hour.toString().padLeft(2, '0')}:${newDateTime.minute.toString().padLeft(2, '0')}';
  }
}

class Event {
  final String name;
  final String startTime;
  final String endTime;
  final String location;
  final String? id; // 新增 id 欄位

  Event({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.id,
  });

  // 轉換為 Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'tag': 1,
    };
  }
}

// 新增行程對話框
class AddEventDialog extends StatefulWidget {
  final DateTime selectedDate;
  final List<Event> existingEvents;

  const AddEventDialog({
    Key? key,
    required this.selectedDate,
    required this.existingEvents,
  }) : super(key: key);

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String? _timeError; // 新增時間錯誤提示

  // 檢查時間是否合理
  bool _isTimeValid() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    return endMinutes > startMinutes;
  }

  // 選擇開始時間
  Future<void> _selectStartTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() {
        _startTime = time;
        // 檢查時間並更新錯誤訊息
        _timeError = _isTimeValid() ? null : '結束時間必須晚於開始時間';
      });
    }
  }

  // 選擇結束時間
  Future<void> _selectEndTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() {
        _endTime = time;
        // 檢查時間並更新錯誤訊息
        _timeError = _isTimeValid() ? null : '結束時間必須晚於開始時間';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新增行程'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '行程名稱'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入行程名稱';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: '地點'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _selectStartTime,
                      child: Text('開始時間: ${_startTime.format(context)}'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: _selectEndTime,
                      child: Text('結束時間: ${_endTime.format(context)}'),
                    ),
                  ),
                ],
              ),
              if (_timeError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _timeError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _isTimeValid()) {
              final newEvent = Event(
                name: _nameController.text,
                startTime:
                    '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                endTime:
                    '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                location: _locationController.text.isEmpty
                    ? '無地點'
                    : _locationController.text,
              );
              Navigator.pop(context, newEvent);
            } else if (!_isTimeValid()) {
              setState(() {
                _timeError = '結束時間必須晚於開始時間';
              });
            }
          },
          child: const Text('確定'),
        ),
      ],
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  Future<void> _initializeCalendar() async {
    await initializeDateFormatting('zh_TW', null);
    await _loadEvents();
    setState(() {
      _isLoading = false;
    });
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // 新增行程
  Future<void> _addEvent() async {
    final selectedDate = _selectedDay ?? _focusedDay;
    final existingEvents = _getEventsForDay(selectedDate);

    final Event? newEvent = await showDialog<Event>(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: selectedDate,
        existingEvents: existingEvents,
      ),
    );

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      if (newEvent != null) {
        try {
          // 1. 將新事件與當日現有事件合併
          final allEvents = [...existingEvents, newEvent];

          // 2. 解決時間衝突
          final resolvedEvents =
              TimeSlotResolver.resolveTimeConflicts(allEvents);

          // 3. 準備批次更新
          final batch = FirebaseFirestore.instance.batch();

          // 4. 處理每個事件
          for (var event in resolvedEvents) {
            if (event.id != null) {
              // 更新現有事件（若時間被調整）
              final docRef = FirebaseFirestore.instance
                  .collection('UserID')
                  .doc(uid)
                  .collection('List')
                  .doc(event.id);

              batch.update(docRef, {
                'name': event.name,
                'start_time': event.startTime,
                'end_time': event.endTime,
                'location': event.location,
                'tag': 1,
              });
            } else {
              // 新增事件到資料庫
              final docRef = FirebaseFirestore.instance
                  .collection('UserID')
                  .doc(uid)
                  .collection('List')
                  .doc();
              batch.set(docRef, {
                'name': event.name,
                'start_time': event.startTime,
                'end_time': event.endTime,
                'location': event.location,
                'date': DateFormat('yyyy/MM/dd').format(selectedDate),
                'tag': 1,
              });
            }
          }

          await batch.commit();
          await _loadEvents();

          // 顯示成功訊息
          if (resolvedEvents.length > existingEvents.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('行程已新增')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('行程已新增，部分時間已自動調整以避免衝突')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('新增行程失敗: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteEvent(Event event) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    String uid = currentUser.uid;

    // 顯示確認的對話框
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: const Text('確定要刪除這個行程嗎？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('刪除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // 如果用戶確認刪除
    if (confirm == true) {
      try {
        // 從 firebase 上刪除資料
        await FirebaseFirestore.instance
            .collection('UserID')
            .doc(uid)
            .collection('List')
            .doc(event.id)
            .delete();

        // reload 事件表
        await _loadEvents();

        // 顯示成功
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('行程已刪除')),
          );
        }
      } catch (e) {
        // error 處理
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadEvents() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      String uid = currentUser.uid;
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('UserID')
          .doc(uid)
          .collection('List')
          .where('tag', isEqualTo: 1)
          .get();

      Map<DateTime, List<Event>> newEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String dateStr = data['date'].toString().replaceAll('"', '');

        try {
          DateTime date = DateFormat('yyyy/MM/dd').parse(dateStr);
          date = normalizeDate(date);

          final event = Event(
            name: data['name'].toString().replaceAll('"', ''),
            startTime: data['start_time'].toString().replaceAll('"', ''),
            endTime: data['end_time'].toString().replaceAll('"', ''),
            location: data['location']?.toString().replaceAll('"', '') ?? '無地點',
            id: doc.id, // 保存文檔 ID
          );

          if (newEvents[date] == null) {
            newEvents[date] = [];
          }
          newEvents[date]!.add(event);
        } catch (e) {
          print('Error processing document: $e');
        }
      }

      // 對每一天的事件進行時間衝突解決
      newEvents.forEach((date, events) {
        newEvents[date] = TimeSlotResolver.resolveTimeConflicts(events);
      });

      setState(() {
        _events = newEvents;
      });
    } catch (e) {
      print('Error loading events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入行程時發生錯誤: $e')),
      );
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = normalizeDate(day);
    return _events[normalizedDay] ?? [];
  }

  Widget _buildEventList() {
    final selectedDate = _selectedDay ?? _focusedDay;
    final events = _getEventsForDay(selectedDate);

    if (events.isEmpty) {
      return const Center(
        child: Text('今日無行程'),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Dismissible(
          key: Key(event.id ?? '${event.name}_${event.startTime}'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          // confirmDismiss: (direction) async {
          //   return await showDialog<bool>(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return AlertDialog(
          //         title: const Text('確認刪除'),
          //         content: const Text('確定要刪除這個行程嗎？'),
          //         actions: <Widget>[
          //           TextButton(
          //             onPressed: () => Navigator.pop(context, false),
          //             child: const Text('取消'),
          //           ),
          //           TextButton(
          //             onPressed: () => Navigator.pop(context, true),
          //             child:
          //                 const Text('刪除', style: TextStyle(color: Colors.red)),
          //           ),
          //         ],
          //       );
          //     },
          //   );
          // },
          onDismissed: (direction) {
            _deleteEvent(event);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            child: ListTile(
              title: Text(
                event.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '時間: ${event.startTime} - ${event.endTime}\n地點: ${event.location}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEvent(event),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('行事曆'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadEvents().then((_) {
                setState(() {
                  _isLoading = false;
                });
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/image/Calendar.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 165),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 65),
                child: TableCalendar<Event>(
                  locale: 'zh_TW',
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2024, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: const CalendarStyle(
                    markersMaxCount: 1,
                    markerDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      color: Colors.black,
                    ),
                    selectedTextStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    defaultTextStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      color: Colors.black,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Color.fromARGB(255, 222, 170, 93),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color.fromARGB(255, 180, 154, 222),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Color.fromARGB(255, 66, 66, 66),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Color.fromARGB(255, 66, 66, 66),
                    ),
                    titleTextStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      fontSize: 20,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    weekendStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 162, 12, 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final selectedDate = _selectedDay ?? _focusedDay;
                    final events = _getEventsForDay(selectedDate);

                    if (events.isEmpty) {
                      return const Center(
                        child: Text('今日無行程'),
                      );
                    }

                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Dismissible(
                          key: Key(
                              event.id ?? '${event.name}_${event.startTime}'),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('確認刪除'),
                                  content: const Text('確定要刪除這個行程嗎？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('刪除',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmed == false) {
                              await _loadEvents();
                            } else {
                              await _deleteEvent(event);
                            }
                            return false;
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              title: Text(
                                event.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '時間: ${event.startTime} - ${event.endTime}\n地點: ${event.location}',
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteEvent(event),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
