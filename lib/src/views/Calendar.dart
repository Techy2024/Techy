import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children: [
        // 背景
        Positioned.fill(
          child: Image.asset(
            'assets/image/Calendar.png', // 背景圖片
            fit: BoxFit.cover, // 調整圖片以覆蓋整個背景
          ),
        ),
        
        // 月曆
        Positioned(
          top: 165, // 設定相對於父容器的上方距離
          left: 60, // 設定相對於父容器的左邊距離
          child: Container(
            width: double.infinity, // 寬度可隨父容器調整
            height: 400, // 固定高度
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 222, 170, 93),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 180, 154, 222),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                // 設定左右箭頭顏色
                leftChevronIcon: Icon(
                  Icons.chevron_left, // 左箭頭圖標
                  color: const Color.fromARGB(255, 66, 66, 66), // 設置左箭頭顏色
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right, // 右箭頭圖標
                  color: const Color.fromARGB(255, 66, 66, 66),  // 設置右箭頭顏色
                ),
              ),
            ),
          ),
        ),
      ],
    )

    );
  }
}