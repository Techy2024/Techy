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
          Positioned.fill(
            child: Image.asset(
              'assets/image/Calendar.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 165),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 65),
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
                    todayTextStyle: TextStyle(
                      fontFamily: '851Tegaki', // 設定字型
                      color: Colors.black,
                    ),
                    selectedTextStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      fontWeight: FontWeight.bold, // 被選中的字型為粗體
                      color: Colors.white,
                    ),
                    defaultTextStyle: TextStyle(
                      fontFamily: '851Tegaki',
                      color: Colors.black,
                    ),
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
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: const Color.fromARGB(255, 66, 66, 66),
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: const Color.fromARGB(255, 66, 66, 66),
                    ),
                    titleTextStyle: TextStyle(
                      fontFamily: '851Tegaki', // 設定字型
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
                      color: const Color.fromARGB(255, 162, 12, 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
