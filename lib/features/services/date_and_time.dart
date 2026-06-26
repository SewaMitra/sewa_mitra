import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../payment/payment_screen.dart';

class DateTimeSelectionScreen extends StatefulWidget {
  final String serviceName;
  final double servicePrice;
  final String providerName;

  const DateTimeSelectionScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.providerName,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  DateTime _currentMonth = DateTime(2026, 5, 1);
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> availableTimes = [
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
  ];

  final List<String> monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  final List<String> weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C1C1E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Date & Time',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stepper
                      Row(
                        children: [
                          _buildStepCircle(1, 'Select\nService', true),
                          Expanded(
                            child: Container(
                                height: 2,
                                color: const Color(0xFFFF8A00)),
                          ),
                          _buildStepCircle(2, 'Date &\nTime', true),
                          Expanded(
                            child: Container(
                                height: 2,
                                color: const Color(0xFFE5E5EA)),
                          ),
                          _buildStepCircle(3, 'Confirm\nBooking', false),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Step 2 of 3',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Calendar
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: const Color(0xFFE5E5EA)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentMonth = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month - 1,
                                          1,
                                        );
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.chevron_left,
                                      color: Color(0xFF8E8E93),
                                      size: 28,
                                    ),
                                  ),
                                  Text(
                                    '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentMonth = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month + 1,
                                          1,
                                        );
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF8E8E93),
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: weekDays
                                    .map((day) => Expanded(
                                          child: Center(
                                            child: Text(
                                              day,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF8E8E93),
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildCalendarDays(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                      const Text(
                        'Available Times',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: availableTimes.map((time) {
                          final isSelected = _selectedTime == time;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedTime = time);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFF8A00)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF8A00)
                                      : const Color(0xFFE5E5EA),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_selectedDate != null &&
                                  _selectedTime != null)
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentScreen(
                                        amount: widget.servicePrice,
                                        bookingId: 'BK-${DateTime.now().millisecondsSinceEpoch}',
                                        serviceName: widget.serviceName,
                                        date: DateFormat('dd MMM yyyy').format(_selectedDate!),
                                        time: _selectedTime!,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A00),
                            disabledBackgroundColor:
                                const Color(0xFFE5E5EA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'CONFIRM BOOKING',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDays() {
    final int daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final int startWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    final DateTime prevMonth =
        DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    final int daysInPrevMonth =
        DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    List<Widget> dayWidgets = [];

    for (int i = startWeekday - 1; i >= 0; i--) {
      dayWidgets.add(_buildDayCell(daysInPrevMonth - i, true));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date =
          DateTime(_currentMonth.year, _currentMonth.month, day);
      final bool isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;
      dayWidgets.add(
          _buildDayCell(day, false, date: date, isSelected: isSelected));
    }

    final int remainingCells = 42 - dayWidgets.length;
    for (int day = 1; day <= remainingCells; day++) {
      dayWidgets.add(_buildDayCell(day, true));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 4,
      mainAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, bool isOtherMonth,
      {DateTime? date, bool isSelected = false}) {
    final bool isToday = date != null &&
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return GestureDetector(
      onTap: () {
        if (!isOtherMonth && date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? const Color(0xFFFF8A00)
              : (isToday && !isOtherMonth)
                  ? const Color(0xFFFF8A00).withOpacity(0.15)
                  : Colors.transparent,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isOtherMonth
                  ? const Color(0xFFC6C6C8)
                  : isSelected
                      ? Colors.white
                      : const Color(0xFF1C1C1E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFF8A00) : Colors.white,
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFFE5E5EA),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF8E8E93),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isActive
                ? const Color(0xFFFF8A00)
                : const Color(0xFFC6C6C8),
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
