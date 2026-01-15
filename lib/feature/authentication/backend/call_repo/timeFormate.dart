import 'package:intl/intl.dart';

String formatCallTime(int millis) {
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat('dd MMM, hh:mm a').format(dt);
}

String formatDuration(int sec) {
  final m = sec ~/ 60;
  final s = sec % 60;
  return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
}
