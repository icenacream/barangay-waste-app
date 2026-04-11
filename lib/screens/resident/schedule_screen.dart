import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/schedule_service.dart';
import '../../models/schedule_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  DateTime _focusedMonth = DateTime.now();
  SettingsModel? _settings;
  List<ExceptionModel> _exceptions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final settings = await _scheduleService.getSettings(user.barangay);
    if (mounted) {
      setState(() {
        _settings = settings;
        _loading = false;
      });
    }

    _scheduleService.getExceptions(user.barangay).listen((exceptions) {
      if (mounted) setState(() => _exceptions = exceptions);
    });
  }

  bool _isCollectionDay(DateTime date) {
    if (_settings == null) return false;
    final exception = _getException(date);
    if (exception != null && exception.isCancelled) return false;
    return _settings!.isCollectionDay(date);
  }

  bool _isCancelledDay(DateTime date) {
    final exception = _getException(date);
    return exception != null && exception.isCancelled;
  }

  ExceptionModel? _getException(DateTime date) {
    final dateKey = date.toIso8601String().substring(0, 10);
    return _exceptions
        .where((e) => e.date.toIso8601String().substring(0, 10) == dateKey)
        .firstOrNull;
  }

  List<DateTime> _getUpcomingDays() {
    final List<DateTime> days = [];
    DateTime check = DateTime.now();
    int safetyCount = 0;
    while (days.length < 5 && safetyCount < 60) {
      if (_isCollectionDay(check)) days.add(check);
      check = check.add(const Duration(days: 1));
      safetyCount++;
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              color: const Color(0xFF1565C0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.watch<AuthProvider>().user?.barangay ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1565C0),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCalendar(),
                          const SizedBox(height: 16),
                          _buildLegend(),
                          const SizedBox(height: 16),
                          const Text(
                            'Upcoming',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._getUpcomingDays().map(_buildScheduleCard),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(const Color(0xFF1565C0), 'Collection day'),
        const SizedBox(width: 16),
        _legendItem(Colors.red, 'Cancelled'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final startWeekday = firstDay.weekday % 7;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  ),
                ),
                icon: const Icon(Icons.chevron_left, color: Color(0xFF1565C0)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              IconButton(
                onPressed: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  ),
                ),
                icon: const Icon(Icons.chevron_right, color: Color(0xFF1565C0)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: daysInMonth + startWeekday,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox();
              final day = index - startWeekday + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                day,
              );
              final isCollection = _isCollectionDay(date);
              final isCancelled = _isCancelledDay(date);
              final isToday =
                  date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;

              Color? bgColor;
              Color textColor = const Color(0xFF333333);

              if (isCancelled) {
                bgColor = Colors.red;
                textColor = Colors.white;
              } else if (isCollection) {
                bgColor = const Color(0xFF1565C0);
                textColor = Colors.white;
              } else if (isToday) {
                bgColor = const Color(0xFFE3F2FD);
                textColor = const Color(0xFF1565C0);
              }

              return Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor,
                      fontWeight: isCollection || isCancelled
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(DateTime date) {
    final user = context.read<AuthProvider>().user;
    final exception = _getException(date);
    final time = (exception != null && exception.isRescheduled)
        ? exception.newTime
        : (_settings?.defaultTime ?? '7:00 AM');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.barangay ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM d, yyyy').format(date),
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 12,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Text(
              exception != null && exception.isRescheduled
                  ? 'Rescheduled'
                  : 'Scheduled',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
